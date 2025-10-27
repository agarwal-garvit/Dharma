//
//  LivesManager.swift
//  Dharma
//
//  Refactored Lives Manager using JSON array for regeneration times
//

import Foundation
import Combine

@MainActor
class LivesManager: ObservableObject {
    static let shared = LivesManager()
    
    @Published var currentLives: Int = 5
    @Published var nextLifeRegenerationTime: Date?
    @Published var isLoading = false
    
    private let databaseService = DatabaseService.shared
    private var userId: UUID?
    private var timer: Timer?
    
    private init() {
        // Timer to check for regeneration every 30 seconds
        startTimer()
    }
    
    // MARK: - Public Methods
    
    func initializeForUser(userId: UUID) async {
        self.userId = userId
        await checkAndRegenerateLives()
    }
    
    func deductLife() async {
        guard let userId = userId else {
            print("⚠️ LivesManager: No userId set")
            return
        }
        
        do {
            // Fetch current lives from database
            var lives = try await databaseService.fetchUserLives(userId: userId)
            
            if lives == nil {
                lives = try await databaseService.initializeUserLives(userId: userId)
            }
            
            guard var userLives = lives else { return }
            
            // Check if user has lives to deduct
            guard userLives.currentLives > 0 else {
                print("⚠️ LivesManager: No lives to deduct")
                currentLives = 0
                return
            }
            
            print("💔 LivesManager: Deducting life - Current: \(userLives.currentLives)/5")
            
            // Deduct the life
            userLives.currentLives -= 1
            
            // Add regeneration time (10 minutes from the latest regeneration time, or from now if no queue)
            let now = Date()
            let formatter = ISO8601DateFormatter()
            
            // Get all existing regeneration times and find the latest one
            let existingTimes = userLives.regenerationTimes.compactMap { timeString in
                formatter.date(from: timeString)
            }
            
            let latestRegenerationTime = existingTimes.max()
            
            // New regeneration time should be 10 minutes after the latest time, or 10 minutes from now if no queue
            let newRegenerationTime: Date
            if let latestTime = latestRegenerationTime, latestTime > now {
                // Stack on top of existing regeneration queue
                newRegenerationTime = latestTime.addingTimeInterval(600)
            } else {
                // No queue or queue has passed, start from now
                newRegenerationTime = now.addingTimeInterval(600)
            }
            
            let regenerationTimeString = formatter.string(from: newRegenerationTime)
            
            // Add to regeneration times array
            userLives.regenerationTimes.append(regenerationTimeString)
            
            // Sort the array to maintain chronological order
            userLives.regenerationTimes.sort()
            
            print("💔 LivesManager: Added regeneration time: \(regenerationTimeString)")
            print("📊 LivesManager: Regeneration queue: \(userLives.regenerationTimes)")
            
            // Update database
            try await databaseService.updateUserLives(lives: userLives)
            
            // Update local state
            currentLives = userLives.currentLives
            nextLifeRegenerationTime = userLives.nextRegenerationTime
            
            print("✅ LivesManager: Life deducted - Current: \(currentLives)/5")
            if let nextTime = nextLifeRegenerationTime {
                print("⏰ LivesManager: Next regeneration at: \(nextTime)")
            }
            
            // Trigger haptic feedback
            HapticManager.shared.incorrectAnswer()
            
        } catch {
            print("❌ LivesManager: Error deducting life: \(error)")
        }
    }
    
    func checkAndRegenerateLives() async {
        guard let userId = userId else {
            print("⚠️ LivesManager: No userId set")
            return
        }
        
        isLoading = true
        
        do {
            // Fetch current lives from database
            var lives = try await databaseService.fetchUserLives(userId: userId)
            
            if lives == nil {
                lives = try await databaseService.initializeUserLives(userId: userId)
            }
            
            guard var userLives = lives else {
                print("❌ LivesManager: Failed to get user lives")
                isLoading = false
                return
            }
            
            print("📊 LivesManager: Processing lives - Current: \(userLives.currentLives)/5")
            print("📊 LivesManager: Regeneration queue: \(userLives.regenerationTimes)")
            
            // Check for lives that should be regenerated
            let now = Date()
            let formatter = ISO8601DateFormatter()
            var needsUpdate = false
            
            // Find times that have passed
            let expiredTimes = userLives.regenerationTimes.filter { timeString in
                guard let time = formatter.date(from: timeString) else { return false }
                return time <= now
            }
            
            if !expiredTimes.isEmpty {
                print("💚 LivesManager: Found \(expiredTimes.count) lives ready to regenerate")
                
                // Regenerate the lives
                userLives.currentLives += expiredTimes.count
                
                // Remove expired times from the array
                userLives.regenerationTimes = userLives.regenerationTimes.filter { timeString in
                    guard let time = formatter.date(from: timeString) else { return true }
                    return time > now
                }
                
                // Ensure we don't exceed 5 lives
                if userLives.currentLives > 5 {
                    userLives.currentLives = 5
                    userLives.regenerationTimes = [] // Clear all regeneration times if at max
                }
                
                needsUpdate = true
                print("💚 LivesManager: Regenerated \(expiredTimes.count) lives - Total now: \(userLives.currentLives)/5")
            }
            
            // Update database if changes were made
            if needsUpdate {
                try await databaseService.updateUserLives(lives: userLives)
                print("✅ LivesManager: Database updated")
            }
            
            // Update local state
            currentLives = userLives.currentLives
            nextLifeRegenerationTime = userLives.nextRegenerationTime
            
            print("✅ LivesManager: Lives check complete - Current: \(currentLives)/5")
            if let nextTime = nextLifeRegenerationTime {
                print("⏰ LivesManager: Next regeneration at: \(nextTime)")
            } else {
                print("⏰ LivesManager: No pending regenerations (all lives active)")
            }
            
        } catch {
            print("❌ LivesManager: Error checking/regenerating lives: \(error)")
        }
        
        isLoading = false
    }
    
    func getTimeUntilNextLife() -> TimeInterval? {
        guard let nextTime = nextLifeRegenerationTime else { return nil }
        let timeInterval = nextTime.timeIntervalSinceNow
        return timeInterval > 0 ? timeInterval : nil
    }
    
    func getFormattedTimeUntilNextLife() -> String {
        guard let timeInterval = getTimeUntilNextLife() else { return "00:00" }
        
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func resetLivesToCleanState() async {
        guard let userId = userId else { return }
        
        do {
            var lives = try await databaseService.fetchUserLives(userId: userId)
            
            if lives == nil {
                lives = try await databaseService.initializeUserLives(userId: userId)
            }
            
            guard var userLives = lives else { return }
            
            // Reset to 5 lives with no regeneration times
            userLives.currentLives = 5
            userLives.regenerationTimes = []
            
            try await databaseService.updateUserLives(lives: userLives)
            
            // Update local state
            currentLives = userLives.currentLives
            nextLifeRegenerationTime = nil
            
            print("🧹 LivesManager: Reset lives to clean state - 5/5 lives")
            
        } catch {
            print("❌ LivesManager: Error resetting lives: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
                await self.checkAndRegenerateLives()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
