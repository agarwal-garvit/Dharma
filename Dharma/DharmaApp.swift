//
//  DharmaApp.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

@main
struct DharmaApp: App {
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
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
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
