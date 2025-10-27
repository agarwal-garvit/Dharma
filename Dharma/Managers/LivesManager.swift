//
//  LivesManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 10/22/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class LivesManager: ObservableObject {
    static let shared = LivesManager()
    
    @Published var currentLives: Int = 5
    @Published var nextLifeRegenerationTime: Date?
    @Published var isLoading: Bool = false
    
    private var timer: AnyCancellable?
    private var userId: UUID?
    private let databaseService = DatabaseService.shared
    
    private init() {
        startTimer()
    }
    
    // MARK: - Public Methods
    
    /// Initialize lives for a user (call on app start)
    func initializeForUser(userId: UUID) async {
        print("🔵 LivesManager: Initializing for user: \(userId)")
        self.userId = userId
        await checkAndRegenerateLives()
        print("🔵 LivesManager: Initialization complete - Lives: \(currentLives)/5")
    }
    
    /// Check database and regenerate any lives that have passed their regeneration time
    func checkAndRegenerateLives() async {
        guard let userId = userId else {
            print("⚠️ LivesManager: No userId set")
            return
        }
        
        isLoading = true
        
        do {
            // Fetch current lives from database
            print("📥 LivesManager: Fetching lives from database...")
            var lives = try await databaseService.fetchUserLives(userId: userId)
            
            // If no lives record exists, initialize one
            if lives == nil {
                print("⚠️ LivesManager: No lives record found, initializing new record...")
                lives = try await databaseService.initializeUserLives(userId: userId)
            }
            
            guard var userLives = lives else {
                print("❌ LivesManager: Failed to get user lives")
                isLoading = false
                return
            }
            
            print("📊 LivesManager: Processing lives data - Current lives: \(userLives.currentLives)/5")
            
            // Check each life slot for regeneration
            var needsUpdate = false
            let now = Date()
            
            // Array of life regeneration times (in order: life 1 through 5)
            let regenerationTimes = [
                userLives.life1RegeneratesAt,
                userLives.life2RegeneratesAt,
                userLives.life3RegeneratesAt,
                userLives.life4RegeneratesAt,
                userLives.life5RegeneratesAt
            ]
            
            // Check each life slot and regenerate if time has passed
            for (index, timeString) in regenerationTimes.enumerated() {
                if let timeString = timeString,
                   let regenerationDate = ISO8601DateFormatter().date(from: timeString),
                   regenerationDate <= now {
                    // This life should be regenerated
                    userLives.currentLives += 1
                    needsUpdate = true
                    
                    print("💚 LivesManager: Life slot \(index + 1) is ready to regenerate (was due at \(regenerationDate))")
                    
                    // Clear the regeneration timestamp for this life (set to nil = NULL in database)
                    switch index {
                    case 0: 
                        userLives.life1RegeneratesAt = nil
                        print("   ✓ Cleared life_1_regenerates_at")
                    case 1: 
                        userLives.life2RegeneratesAt = nil
                        print("   ✓ Cleared life_2_regenerates_at")
                    case 2: 
                        userLives.life3RegeneratesAt = nil
                        print("   ✓ Cleared life_3_regenerates_at")
                    case 3: 
                        userLives.life4RegeneratesAt = nil
                        print("   ✓ Cleared life_4_regenerates_at")
                    case 4: 
                        userLives.life5RegeneratesAt = nil
                        print("   ✓ Cleared life_5_regenerates_at")
                    default: break
                    }
                    
                    print("💚 LivesManager: Regenerated life - Total lives now: \(userLives.currentLives)")
                    
                    // If this was the first life back (from 0 to 1), reset the regeneration queue
                    // This prevents the old stacking from carrying over
                    if userLives.currentLives == 1 {
                        print("💡 LivesManager: First life back - resetting regeneration queue to prevent old stacking")
                        userLives.life2RegeneratesAt = nil
                        userLives.life3RegeneratesAt = nil
                        userLives.life4RegeneratesAt = nil
                        userLives.life5RegeneratesAt = nil
                    }
                }
            }
            
            // Ensure lives don't exceed 5
            if userLives.currentLives > 5 {
                userLives.currentLives = 5
                needsUpdate = true
            }
            
            // Update database if changes were made
            if needsUpdate {
                print("📤 LivesManager: Updating database with regenerated lives...")
                print("   Before update - Life 1: \(userLives.life1RegeneratesAt ?? "NULL")")
                print("   Before update - Life 2: \(userLives.life2RegeneratesAt ?? "NULL")")
                print("   Before update - Life 3: \(userLives.life3RegeneratesAt ?? "NULL")")
                print("   Before update - Life 4: \(userLives.life4RegeneratesAt ?? "NULL")")
                print("   Before update - Life 5: \(userLives.life5RegeneratesAt ?? "NULL")")
                
                try await databaseService.updateUserLives(lives: userLives)
                print("✅ LivesManager: Database updated successfully")
                
                // Re-fetch to verify the update
                print("🔄 LivesManager: Verifying database state...")
                if let verifiedLives = try await databaseService.fetchUserLives(userId: userId) {
                    userLives = verifiedLives
                    print("✅ LivesManager: Verification complete - DB shows \(verifiedLives.currentLives) lives")
                    print("   After verification - Life 1: \(verifiedLives.life1RegeneratesAt ?? "NULL")")
                    print("   After verification - Life 2: \(verifiedLives.life2RegeneratesAt ?? "NULL")")
                    print("   After verification - Life 3: \(verifiedLives.life3RegeneratesAt ?? "NULL")")
                    print("   After verification - Life 4: \(verifiedLives.life4RegeneratesAt ?? "NULL")")
                    print("   After verification - Life 5: \(verifiedLives.life5RegeneratesAt ?? "NULL")")
                }
            }
            
            // Always update local state to match database (even if no regeneration occurred)
            currentLives = userLives.currentLives
            updateNextRegenerationTime(from: userLives)
            
            print("✅ LivesManager: Lives check complete - Current: \(currentLives)/5")
            if let nextRegen = nextLifeRegenerationTime {
                print("⏰ LivesManager: Next regeneration at: \(nextRegen)")
            } else {
                print("⏰ LivesManager: No pending regenerations (all lives active)")
            }
            
        } catch {
            print("❌ LivesManager: Error checking/regenerating lives: \(error)")
        }
        
        isLoading = false
    }
    
    /// Deduct a life when user answers incorrectly
    func deductLife() async {
        guard let userId = userId else {
            print("⚠️ LivesManager: No userId set")
            return
        }
        
        do {
            // Always fetch fresh data from database to avoid race conditions
            var lives = try await databaseService.fetchUserLives(userId: userId)
            
            if lives == nil {
                lives = try await databaseService.initializeUserLives(userId: userId)
            }
            
            guard var userLives = lives else { return }
            
            // Check database state, not local state
            guard userLives.currentLives > 0 else {
                print("⚠️ LivesManager: No lives to deduct (database has 0)")
                currentLives = 0  // Sync local state
                return
            }
            
            print("💔 LivesManager: Deducting life - Current DB state: \(userLives.currentLives)/5")
            
            // Deduct the life
            userLives.currentLives -= 1
            
            // Find the next available life slot and set its regeneration time
            let now = Date()
            let tenMinutesLater = now.addingTimeInterval(600) // 10 minutes = 600 seconds
            
            // Get all existing regeneration times to find the latest one
            let regenerationTimes = [
                userLives.life1RegeneratesAt,
                userLives.life2RegeneratesAt,
                userLives.life3RegeneratesAt,
                userLives.life4RegeneratesAt,
                userLives.life5RegeneratesAt
            ].compactMap { timeString -> Date? in
                guard let timeString = timeString else { return nil }
                return ISO8601DateFormatter().date(from: timeString)
            }
            
            // Find the latest regeneration time (for stacking)
            let latestRegenerationTime = regenerationTimes.max()
            
            // New regeneration time should be 10 minutes after the latest time, or 10 minutes from now if no queue
            let newRegenerationTime: Date
            if let latestTime = latestRegenerationTime, latestTime > now {
                // Stack on top of existing regeneration queue
                newRegenerationTime = latestTime.addingTimeInterval(600)
            } else {
                // No queue or queue has passed, start from now
                newRegenerationTime = tenMinutesLater
            }
            
            // Special case: If user has 0 lives, the first regeneration should always be 10 minutes from now
            // This prevents the user from waiting too long to get their first life back
            if userLives.currentLives == 0 {
                newRegenerationTime = tenMinutesLater
                print("💡 LivesManager: User has 0 lives - setting first regeneration to 10 minutes from now")
            }
            
            let newRegenerationTimeString = ISO8601DateFormatter().string(from: newRegenerationTime)
            
            // Assign to the life slot that corresponds to the life that was just lost
            // If currentLives = 4 (after deduction), assign to life5RegeneratesAt (life 5 was lost)
            // If currentLives = 3 (after deduction), assign to life4RegeneratesAt (life 4 was lost)
            // And so on...
            let assignedSlot = userLives.currentLives + 1
            
            switch assignedSlot {
            case 5:
                userLives.life5RegeneratesAt = newRegenerationTimeString
            case 4:
                userLives.life4RegeneratesAt = newRegenerationTimeString
            case 3:
                userLives.life3RegeneratesAt = newRegenerationTimeString
            case 2:
                userLives.life2RegeneratesAt = newRegenerationTimeString
            case 1:
                userLives.life1RegeneratesAt = newRegenerationTimeString
            default:
                print("⚠️ LivesManager: Invalid life slot assignment: \(assignedSlot)")
            }
            
            print("💔 LivesManager: Assigned regeneration to life slot \(assignedSlot)")
            print("📤 LivesManager: Updating database after life deduction...")
            
            // Update database
            try await databaseService.updateUserLives(lives: userLives)
            
            // Re-fetch to verify the update and get exact database state
            print("🔄 LivesManager: Verifying database state after deduction...")
            if let verifiedLives = try await databaseService.fetchUserLives(userId: userId) {
                userLives = verifiedLives
                print("✅ LivesManager: Verification complete - DB confirms \(verifiedLives.currentLives) lives")
            }
            
            // Update local state to match verified database state
            currentLives = userLives.currentLives
            updateNextRegenerationTime(from: userLives)
            
            print("✅ LivesManager: Life deduction complete - Local state: \(currentLives)/5")
            print("⏰ LivesManager: Will regenerate at: \(newRegenerationTime)")
            
            // Trigger haptic feedback
            HapticManager.shared.incorrectAnswer()
            
        } catch {
            print("❌ LivesManager: Error deducting life: \(error)")
        }
    }
    
    /// Get time until next life regenerates (in seconds)
    func getTimeUntilNextLife() -> TimeInterval? {
        guard let nextTime = nextLifeRegenerationTime else { return nil }
        let timeInterval = nextTime.timeIntervalSinceNow
        return timeInterval > 0 ? timeInterval : nil
    }
    
    /// Get formatted time string (MM:SS) until next life
    func getFormattedTimeUntilNextLife() -> String? {
        guard let timeInterval = getTimeUntilNextLife() else { return nil }
        
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Manually trigger regeneration check (for debugging/testing)
    func manualRegenerationCheck() async {
        print("🔧 LivesManager: Manual regeneration check triggered")
        await checkAndRegenerateLives()
    }
    
    /// Reset lives to clean state (for debugging/testing)
    /// This ensures all regeneration timestamps are NULL when user has full lives
    func resetLivesToCleanState() async {
        guard let userId = userId else {
            print("⚠️ LivesManager: No userId set")
            return
        }
        
        do {
            var lives = try await databaseService.fetchUserLives(userId: userId)
            
            if lives == nil {
                lives = try await databaseService.initializeUserLives(userId: userId)
            }
            
            guard var userLives = lives else { return }
            
            // If user has 5 lives, all regeneration timestamps should be NULL
            if userLives.currentLives == 5 {
                userLives.life1RegeneratesAt = nil
                userLives.life2RegeneratesAt = nil
                userLives.life3RegeneratesAt = nil
                userLives.life4RegeneratesAt = nil
                userLives.life5RegeneratesAt = nil
                
                try await databaseService.updateUserLives(lives: userLives)
                print("🧹 LivesManager: Reset lives to clean state - all regeneration timestamps cleared")
            }
            
            // Update local state
            currentLives = userLives.currentLives
            updateNextRegenerationTime(from: userLives)
            
        } catch {
            print("❌ LivesManager: Error resetting lives to clean state: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func updateNextRegenerationTime(from lives: DBUserLives) {
        // Find the earliest regeneration time that's in the future
        let regenerationTimes = [
            lives.life1RegeneratesAt,
            lives.life2RegeneratesAt,
            lives.life3RegeneratesAt,
            lives.life4RegeneratesAt,
            lives.life5RegeneratesAt
        ].compactMap { timeString -> Date? in
            guard let timeString = timeString else { return nil }
            return ISO8601DateFormatter().date(from: timeString)
        }.filter { $0 > Date() } // Only future times
        
        nextLifeRegenerationTime = regenerationTimes.min()
    }
    
    private func startTimer() {
        // Timer fires every second to update countdown and check for regeneration
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    
                    // Check for regeneration if we have any pending regeneration times
                    if let nextTime = self.nextLifeRegenerationTime,
                       nextTime <= Date() {
                        print("⏰ LivesManager: Timer triggered regeneration check (next time: \(nextTime))")
                        await self.checkAndRegenerateLives()
                    }
                }
            }
    }
}

