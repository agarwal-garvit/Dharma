//
//  AuthManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import SwiftUI
import Supabase
import GoogleSignIn

@Observable
class DharmaAuthManager {
    static let shared = DharmaAuthManager()
    
    private let supabase: SupabaseClient
    private var currentUser: Auth.User?
    private var authStateListenerStarted = false
    
    var isAuthenticated: Bool {
        return currentUser != nil
    }
    
    var user: Auth.User? {
        return currentUser
    }
    
    private init() {
        // Initialize Supabase client
        self.supabase = SupabaseClient(
            supabaseURL: Config.supabaseURLObject,
            supabaseKey: Config.supabaseKey
        )
        
        // Check for existing session
        Task {
            await checkAuthState()
        }
    }
    
    // MARK: - Authentication State
    
    @MainActor
    private func checkAuthState() async {
        do {
            let session = try await supabase.auth.session
            self.currentUser = session.user
            print("🔍 [AUTH] Session found - User ID: \(session.user.id)")
            
            // Post notification that auth state has been determined
            NotificationCenter.default.post(name: .authStateChanged, object: nil)
        } catch {
            print("⚠️ [AUTH] No existing session: \(error)")
            self.currentUser = nil
        }
    }
    
    // MARK: - Email Sign In
    
    @MainActor
    func signInWithEmail(email: String, password: String) async throws {
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            self.currentUser = session.user
            
            // Initialize user in custom users table if needed
            await initializeUserIfNeeded()
            
            // Record login session with device info
            await recordLoginSession(authMethod: "email")
            
            // Update streak
            await updateStreakIfNeeded()
            
            print("Successfully signed in with email: \(email)")
        } catch {
            print("Email Sign In failed: \(error)")
            throw error
        }
    }
    
    @MainActor
    func signUpWithEmail(email: String, password: String, displayName: String? = nil) async throws {
        do {
            let session = try await supabase.auth.signUp(email: email, password: password)
            self.currentUser = session.user
            
            // Initialize user in custom users table
            await initializeUserIfNeeded(displayName: displayName)
            
            // Record login session (first login)
            await recordLoginSession(authMethod: "email", isFirstLogin: true)
            
            // Update streak
            await updateStreakIfNeeded()
            
            print("Successfully signed up with email: \(email)")
            
            // Post notification to update UI state
            NotificationCenter.default.post(name: .authStateChanged, object: nil)
        } catch {
            print("Email Sign Up failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Google Sign In
    
    @MainActor
    func signInWithGoogle() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            throw DharmaAuthError.noPresentingViewController
        }
        
        do {
            // Start Google Sign In flow
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let user = result.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw DharmaAuthError.noGoogleToken
            }
            
            // Check if this is a new user (for first login tracking)
            let isNewUser = await checkIfNewUser()
            
            // Sign in to Supabase with Google token
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken
                )
            )
            
            self.currentUser = session.user
            
            // Initialize user in custom users table if needed
            await initializeUserIfNeeded(displayName: user.profile?.name)
            
            // Record login session with device info
            await recordLoginSession(authMethod: "google", isFirstLogin: isNewUser)
            
            // Update streak
            await updateStreakIfNeeded()
            
            print("Successfully signed in with Google: \(session.user.email ?? "No email")")
            
        } catch {
            print("Google Sign In failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Sign Out
    
    @MainActor
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            self.currentUser = nil
            
            // Post notification to update UI state
            NotificationCenter.default.post(name: .authStateChanged, object: nil)
            
            print("Successfully signed out")
        } catch {
            print("Sign out failed: \(error)")
            throw error
        }
    }
    
    // MARK: - User Profile Management
    
    @MainActor
    func fetchUserDisplayName() async -> String? {
        guard let currentUser = self.currentUser else { return nil }
        
        do {
            let users: [UserRecord] = try await supabase.database
                .from("users")
                .select()
                .eq("id", value: currentUser.id)
                .execute()
                .value
            
            return users.first?.display_name
        } catch {
            print("Failed to fetch user display name: \(error)")
            return nil
        }
    }
    
    // MARK: - User Stats Management
    
    @MainActor
    func fetchUserStats() async -> UserStats? {
        guard let currentUser = self.currentUser else { return nil }
        
        do {
            let stats: [UserStats] = try await supabase.database
                .from("user_stats")
                .select()
                .eq("user_id", value: currentUser.id)
                .execute()
                .value
            
            return stats.first
        } catch {
            print("Failed to fetch user stats: \(error)")
            return nil
        }
    }
    
    @MainActor
    func updateStreakIfNeeded() async {
        guard let currentUser = self.currentUser else { return }
        
        do {
            let databaseService = DatabaseService.shared
            
            // Calculate and update streak
            let currentStreak = try await databaseService.calculateUserStreak(userId: currentUser.id)
            
            // Check for streak milestones and award XP
            if currentStreak == 7 || currentStreak == 30 || currentStreak == 100 {
                _ = try await databaseService.awardStreakMilestoneXP(userId: currentUser.id, streakDays: currentStreak)
            }
            
            // Update user stats to reflect new streak
            await updateUserStats()
            
            print("✅ Streak updated: \(currentStreak) days")
        } catch {
            print("Failed to update streak: \(error)")
        }
    }
    
    @MainActor
    func updateUserStats(xpToAdd: Int = 0, lessonCompleted: Bool = false) async {
        guard let currentUser = self.currentUser else { return }
        
        do {
            // Use the new database service to get current metrics
            let databaseService = DatabaseService.shared
            let currentMetrics = try await databaseService.getUserMetrics(userId: currentUser.id)
            
            // Calculate new values
            let newXpTotal = (currentMetrics?.totalXp ?? 0) + xpToAdd
            let newStreakCount = try await databaseService.calculateUserStreak(userId: currentUser.id)
            let newLongestStreak = max(currentMetrics?.longestStreak ?? 0, newStreakCount)
            let newLastActiveDate = ISO8601DateFormatter().string(from: Date())
            
            // Update or insert stats
            let updatedStats = UserStats(
                user_id: currentUser.id,
                xp_total: newXpTotal,
                streak_count: newStreakCount,
                longest_streak: newLongestStreak,
                last_active_date: newLastActiveDate
            )
            
            if currentMetrics != nil {
                // Update existing stats
                try await supabase.database
                    .from("user_stats")
                    .update(updatedStats)
                    .eq("user_id", value: currentUser.id)
                    .execute()
            } else {
                // Insert new stats
                try await supabase.database
                    .from("user_stats")
                    .insert(updatedStats)
                    .execute()
            }
            
            print("Successfully updated user stats")
        } catch {
            print("Failed to update user stats: \(error)")
        }
    }
    
    @MainActor
    private func calculateCurrentStreak() async -> Int {
        guard let currentUser = self.currentUser else { return 0 }
        
        do {
            // Get all lesson sessions for the user, ordered by date
            let sessions: [UserLessonSession] = try await supabase.database
                .from("user_lesson_sessions")
                .select()
                .eq("user_id", value: currentUser.id)
                .order("started_at", ascending: false)
                .execute()
                .value
            
            // Calculate streak based on consecutive days with activity
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            var streak = 0
            var currentDate = today
            
            for session in sessions {
                let sessionDate = calendar.startOfDay(for: ISO8601DateFormatter().date(from: session.started_at) ?? Date())
                let daysDifference = calendar.dateComponents([.day], from: sessionDate, to: currentDate).day ?? 0
                
                if daysDifference == 0 {
                    // Same day, continue
                    continue
                } else if daysDifference == 1 {
                    // Consecutive day
                    streak += 1
                    currentDate = sessionDate
                } else {
                    // Streak broken
                    break
                }
            }
            
            // If we have any sessions today, add 1 to streak
            if !sessions.isEmpty {
                let firstSessionDate = calendar.startOfDay(for: ISO8601DateFormatter().date(from: sessions[0].started_at) ?? Date())
                if calendar.isDate(firstSessionDate, inSameDayAs: today) {
                    streak += 1
                }
            }
            
            return max(streak, 1) // Minimum streak of 1 if user has any activity
        } catch {
            print("Failed to calculate streak: \(error)")
            return 0
        }
    }
    
    @MainActor
    func getCompletedLessonsCount() async -> Int {
        guard let currentUser = self.currentUser else { return 0 }
        
        do {
            let progress: [UserLessonProgress] = try await supabase.database
                .from("user_lesson_progress")
                .select()
                .eq("user_id", value: currentUser.id)
                .eq("status", value: "COMPLETED")
                .execute()
                .value
            
            return progress.count
        } catch {
            print("Failed to fetch completed lessons: \(error)")
            return 0
        }
    }
    
    @MainActor
    func getUserMetrics() async -> DBUserMetrics? {
        guard let currentUser = self.currentUser else { return nil }
        
        do {
            let databaseService = DatabaseService.shared
            return try await databaseService.getUserMetrics(userId: currentUser.id)
        } catch {
            print("Failed to fetch user metrics: \(error)")
            return nil
        }
    }
    
    @MainActor
    func getLoginSessions(limit: Int = 100) async -> [DBUserLoginSession] {
        guard let currentUser = self.currentUser else { return [] }
        
        do {
            let databaseService = DatabaseService.shared
            return try await databaseService.fetchUserLoginHistory(userId: currentUser.id, limit: limit)
        } catch {
            print("Failed to fetch login sessions: \(error)")
            return []
        }
    }
    
    @MainActor
    func recordLessonCompletion(lessonId: String) async {
        guard let currentUser = self.currentUser else { return }
        
        do {
            // Record lesson session
            let session = UserLessonSession(
                id: UUID(),
                user_id: currentUser.id,
                lesson_id: UUID(uuidString: lessonId) ?? UUID(),
                started_at: ISO8601DateFormatter().string(from: Date()),
                completed_at: ISO8601DateFormatter().string(from: Date()),
                duration_seconds: nil
            )
            
            try await supabase.database
                .from("user_lesson_sessions")
                .insert(session)
                .execute()
            
            // Update lesson progress
            let progress = UserLessonProgress(
                user_id: currentUser.id,
                lesson_id: UUID(uuidString: lessonId) ?? UUID(),
                status: "COMPLETED",
                started_at: ISO8601DateFormatter().string(from: Date()),
                completed_at: ISO8601DateFormatter().string(from: Date()),
                last_seen_at: ISO8601DateFormatter().string(from: Date()),
                last_score_pct: nil,
                best_score_pct: nil,
                total_completions: 1
            )
            
            try await supabase.database
                .from("user_lesson_progress")
                .upsert(progress)
                .execute()
            
            // Award XP based on performance (base XP + bonus for good scores)
            let baseXP = 25
            let bonusXP = 0 // Will be calculated based on quiz score if available
            await updateUserStats(xpToAdd: baseXP + bonusXP, lessonCompleted: true)
            
            print("Successfully recorded lesson completion for lesson: \(lessonId)")
        } catch {
            print("Failed to record lesson completion: \(error)")
        }
    }
    
    // MARK: - Login Session Tracking
    
    @MainActor
    private func recordLoginSession(authMethod: String, isFirstLogin: Bool = false) async {
        print("🔍 [LOGIN_TRACKING] recordLoginSession called with method: \(authMethod)")
        
        guard let currentUser = self.currentUser else {
            print("⚠️ [LOGIN_TRACKING] No current user in recordLoginSession")
            return
        }
        
        print("🔍 [LOGIN_TRACKING] User ID: \(currentUser.id)")
        
        do {
            let databaseService = DatabaseService.shared
            
            // Get device information
            let deviceModel = await getDeviceModel()
            let deviceOS = await getDeviceOS()
            let appVersion = getAppVersion()
            
            print("🔍 [LOGIN_TRACKING] Device info - Model: \(deviceModel), OS: \(deviceOS), Version: \(appVersion)")
            
            let session = try await databaseService.recordLoginSession(
                userId: currentUser.id,
                authMethod: authMethod,
                deviceModel: deviceModel,
                deviceOS: deviceOS,
                appVersion: appVersion,
                isFirstLogin: isFirstLogin
            )
            
            print("✅ [LOGIN_TRACKING] Login session tracked successfully - ID: \(session.id)")
        } catch {
            print("❌ [LOGIN_TRACKING] Failed to record login session: \(error)")
            print("❌ [LOGIN_TRACKING] Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ [LOGIN_TRACKING] Error domain: \(nsError.domain), code: \(nsError.code)")
            }
        }
    }
    
    @MainActor
    private func checkIfNewUser() async -> Bool {
        guard let currentUser = self.currentUser else { return false }
        
        do {
            let existingUser: [UserRecord] = try await supabase.database
                .from("users")
                .select()
                .eq("id", value: currentUser.id)
                .execute()
                .value
            
            return existingUser.isEmpty
        } catch {
            print("Failed to check if new user: \(error)")
            return false
        }
    }
    
    private func getDeviceModel() async -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // Map identifier to friendly name
        let deviceMap: [String: String] = [
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 14",
            "iPhone15,5": "iPhone 14 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone16,3": "iPhone 15",
            "iPhone16,4": "iPhone 15 Plus",
            "arm64": "Simulator"
        ]
        
        return deviceMap[identifier] ?? identifier
    }
    
    private func getDeviceOS() async -> String {
        let osVersion = UIDevice.current.systemVersion
        return "iOS \(osVersion)"
    }
    
    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "Unknown"
    }
    
    // MARK: - User Initialization
    
    @MainActor
    private func initializeUserIfNeeded(displayName: String? = nil) async {
        guard let currentUser = self.currentUser else { return }
        
        do {
            // Check if user already exists in our custom users table
            let existingUser: [UserRecord] = try await supabase.database
                .from("users")
                .select()
                .eq("id", value: currentUser.id)
                .execute()
                .value
            
            if existingUser.isEmpty {
                // User doesn't exist, create them
                let newUser = UserRecord(
                    id: currentUser.id,
                    email: currentUser.email ?? "",
                    password_hash: "", // Not needed for OAuth users
                    display_name: displayName ?? (currentUser.userMetadata["full_name"] as? String),
                    created_at: ISO8601DateFormatter().string(from: Date()),
                    status: "active"
                )
                
                try await supabase.database
                    .from("users")
                    .insert(newUser)
                    .execute()
                
                // Initialize user stats
                let userStats = UserStats(
                    user_id: currentUser.id,
                    xp_total: 0,
                    streak_count: 0,
                    longest_streak: 0,
                    last_active_date: nil
                )
                
                try await supabase.database
                    .from("user_stats")
                    .insert(userStats)
                    .execute()
                
                // Initialize survey response for new user
                let databaseService = DatabaseService.shared
                _ = try await databaseService.createSurveyResponse(userId: currentUser.id)
                
                print("Successfully initialized new user: \(currentUser.email ?? "No email")")
            } else {
                print("User already exists in database")
            }
        } catch {
            print("Failed to initialize user: \(error)")
        }
    }
    
    // MARK: - Session Management
    
    func startAuthStateListener() {
        // Prevent multiple listeners from being started
        guard !authStateListenerStarted else { return }
        authStateListenerStarted = true
        
        Task {
            for await state in supabase.auth.authStateChanges {
                await MainActor.run {
                    switch state.event {
                    case .signedIn:
                        self.currentUser = state.session?.user
                    case .signedOut:
                        self.currentUser = nil
                    case .tokenRefreshed:
                        self.currentUser = state.session?.user
                    case .passwordRecovery:
                        break
                    case .userUpdated:
                        self.currentUser = state.session?.user
                    @unknown default:
                        break
                    }
                    
                    // Post notification for auth state change
                    NotificationCenter.default.post(name: .authStateChanged, object: nil)
                }
            }
        }
    }
}

// MARK: - Database Models

struct UserRecord: Codable {
    let id: UUID
    let email: String
    let password_hash: String
    let display_name: String?
    let created_at: String
    let status: String
}

struct UserStats: Codable {
    let user_id: UUID
    let xp_total: Int
    let streak_count: Int
    let longest_streak: Int
    let last_active_date: String?
}

struct UserLessonSession: Codable {
    let id: UUID
    let user_id: UUID
    let lesson_id: UUID
    let started_at: String
    let completed_at: String?
    let duration_seconds: Int?
}

struct UserLessonProgress: Codable {
    let user_id: UUID
    let lesson_id: UUID
    let status: String
    let started_at: String?
    let completed_at: String?
    let last_seen_at: String?
    let last_score_pct: Double?
    let best_score_pct: Double?
    let total_completions: Int
}

// MARK: - Auth Errors

enum DharmaAuthError: LocalizedError {
    case noPresentingViewController
    case noGoogleToken
    case signInFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noPresentingViewController:
            return "Unable to present Google Sign In"
        case .noGoogleToken:
            return "Failed to get Google authentication token"
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        }
    }
}
