//
//  DharmaApp.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import GoogleSignIn
import UIKit
import Supabase

@main
struct DharmaApp: App {
    @State private var isAuthenticated = false
    @State private var hasCompletedSurvey = false
    @State private var isCheckingSurveyStatus = true
    
    private let authManager = DharmaAuthManager.shared
    private let surveyManager = SurveyManager.shared
    
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
                    } else if isCheckingSurveyStatus {
                        // Show loading while checking survey status
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(ThemeManager.appBackground)
                    } else if !hasCompletedSurvey {
                        SurveyView()
                    } else {
                        MainTabView()
                            .onAppear {
                                // Initialize managers
                                _ = DataManager.shared
                                _ = AudioManager.shared
                                _ = HapticManager.shared
                            }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .authStateChanged)) { _ in
                    let wasAuthenticated = isAuthenticated
                    isAuthenticated = authManager.isAuthenticated
                    
                    // Update streak when user becomes authenticated
                    if !wasAuthenticated && isAuthenticated {
                        Task {
                            await authManager.updateStreakIfNeeded()
                            // Notify that streak has been updated
                            NotificationCenter.default.post(name: .streakUpdated, object: nil)
                            
                            // Check survey status for authenticated user
                            if let userId = authManager.user?.id {
                                await surveyManager.checkSurveyStatus(userId: userId)
                                hasCompletedSurvey = surveyManager.hasCompletedSurvey
                                isCheckingSurveyStatus = false
                            }
                        }
                    } else if !isAuthenticated {
                        // User signed out - reset survey state
                        hasCompletedSurvey = false
                        isCheckingSurveyStatus = true
                        surveyManager.resetSurveyState()
                    }
                }
                .onAppear {
                    print("🔍 [LOGIN_TRACKING] App launched")
                    
                    // Start listening for auth state changes (only once)
                    authManager.startAuthStateListener()
                    
                    // Record app launch/open for session tracking
                    // Use a slight delay to let auth state be determined
                    Task {
                        // Wait a moment for auth state to be determined
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        
                        isAuthenticated = authManager.isAuthenticated
                        print("🔍 [LOGIN_TRACKING] Auth state determined - isAuthenticated: \(isAuthenticated)")
                        
                        if isAuthenticated {
                            print("🔍 [LOGIN_TRACKING] User is authenticated, recording app open...")
                            // Record this app open as a login session
                            await recordAppOpen()
                            // Update streak
                            await authManager.updateStreakIfNeeded()
                            // Notify that streak has been updated
                            NotificationCenter.default.post(name: .streakUpdated, object: nil)
                            
                            // Check survey status for authenticated user
                            if let userId = authManager.user?.id {
                                await surveyManager.checkSurveyStatus(userId: userId)
                                hasCompletedSurvey = surveyManager.hasCompletedSurvey
                                isCheckingSurveyStatus = false
                            }
                            
                            print("✅ [LOGIN_TRACKING] Streak update completed, notification posted")
                        } else {
                            print("⚠️ [LOGIN_TRACKING] User not authenticated - skipping login tracking")
                            isCheckingSurveyStatus = false
                        }
                    }
                    
                    // Debug configuration (remove in production)
                    #if DEBUG
                    Config.debugInfoPlist()
                    #endif
                }
            }
        }
    }
    
    private func recordAppOpen() async {
        // Record that the user opened the app (counts as a login session)
        print("🔍 [LOGIN_TRACKING] recordAppOpen() called")
        
        guard let userId = authManager.user?.id else {
            print("⚠️ [LOGIN_TRACKING] No user ID found - user not authenticated")
            return
        }
        
        print("🔍 [LOGIN_TRACKING] User ID: \(userId)")
        
        do {
            let databaseService = DatabaseService.shared
            let deviceModel = await getDeviceModel()
            let deviceOS = await getDeviceOS()
            let appVersion = getAppVersion()
            
            print("🔍 [LOGIN_TRACKING] Device: \(deviceModel), OS: \(deviceOS), Version: \(appVersion)")
            
            let session = try await databaseService.recordLoginSession(
                userId: userId,
                authMethod: "app_open",
                deviceModel: deviceModel,
                deviceOS: deviceOS,
                appVersion: appVersion,
                isFirstLogin: false
            )
            
            print("✅ [LOGIN_TRACKING] App open recorded as login session - ID: \(session.id)")
        } catch {
            print("❌ [LOGIN_TRACKING] Failed to record app open: \(error)")
            print("❌ [LOGIN_TRACKING] Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ [LOGIN_TRACKING] Error domain: \(nsError.domain), code: \(nsError.code)")
                print("❌ [LOGIN_TRACKING] User info: \(nsError.userInfo)")
            }
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
    static let authStateChanged = Notification.Name("authStateChanged")
    static let switchToProgressTab = Notification.Name("switchToProgressTab")
    static let lessonCompleted = Notification.Name("lessonCompleted")
    static let streakUpdated = Notification.Name("streakUpdated")
}
