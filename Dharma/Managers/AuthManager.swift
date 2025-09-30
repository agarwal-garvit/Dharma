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
    
    var isAuthenticated: Bool {
        return currentUser != nil
    }
    
    var user: Auth.User? {
        return currentUser
    }
    
    private init() {
        // Initialize Supabase client
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: "https://cifjluhwhifwxiyzyrzx.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpZmpsdWh3aGlmd3hpeXp5cnp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyNjQ2NTcsImV4cCI6MjA3NDg0MDY1N30.rAZ55o33qeVsYkFoooIZt3LMB-3d2c5-7e0GgqnG_B4"
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
        } catch {
            print("No existing session: \(error)")
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
            
            print("Successfully signed up with email: \(email)")
        } catch {
            print("Email Sign Up failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Google Sign In
    
    @MainActor
    func signInWithGoogle() async throws {
        guard let presentingViewController = await UIApplication.shared.windows.first?.rootViewController else {
            throw DharmaAuthError.noPresentingViewController
        }
        
        do {
            // Start Google Sign In flow
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let user = result.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw DharmaAuthError.noGoogleToken
            }
            
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
            print("Successfully signed out")
        } catch {
            print("Sign out failed: \(error)")
            throw error
        }
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
                    display_name: displayName ?? currentUser.userMetadata["full_name"] as? String,
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
