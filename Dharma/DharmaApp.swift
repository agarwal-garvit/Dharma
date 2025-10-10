//
//  DharmaApp.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import GoogleSignIn

@main
struct DharmaApp: App {
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var isAuthenticated = false
    
    private let authManager = DharmaAuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Global app background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                Group {
                    if !isAuthenticated {
                        SignInView()
                            .onAppear {
                                // Initialize Google Sign In
                                setupGoogleSignIn()
                            }
                    } else if hasCompletedOnboarding {
                        MainTabView()
                            .onAppear {
                                // Initialize managers
                                _ = DataManager.shared
                                _ = AudioManager.shared
                                _ = HapticManager.shared
                            }
                    } else {
                        OnboardingView()
                            .onAppear {
                                // Initialize managers
                                _ = DataManager.shared
                                _ = AudioManager.shared
                                _ = HapticManager.shared
                            }
                            .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                                hasCompletedOnboarding = true
                            }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .authStateChanged)) { _ in
                    isAuthenticated = authManager.isAuthenticated
                }
                .onAppear {
                    // Check initial auth state
                    isAuthenticated = authManager.isAuthenticated
                    
                    // Start listening for auth state changes (only once)
                    authManager.startAuthStateListener()
                    
                    // Debug configuration (remove in production)
                    #if DEBUG
                    Config.debugInfoPlist()
                    #endif
                }
            }
        }
    }
    
    private func setupGoogleSignIn() {
        // Configure Google Sign In using Info.plist
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            print("Warning: GIDClientID not found in Info.plist")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
    static let authStateChanged = Notification.Name("authStateChanged")
}
