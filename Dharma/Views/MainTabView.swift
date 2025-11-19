//
//  MainTabView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import Combine

struct MainTabView: View {
    @State private var selectedTab = 0  // Start on Daily view
    @State private var dataManager = DataManager.shared
    @State private var livesManager = LivesManager.shared
    
    init() {
        // Set the tab bar background
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 240/255, green: 245/255, blue: 248/255, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DailyView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("Daily")
                }
                .tag(0)
            
            LearnView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Learn")
                }
                .tag(1)
            
            ChatbotView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("AI")
                }
                .tag(2)
            
            ProfileView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.orange)
        .onReceive(NotificationCenter.default.publisher(for: .switchToProgressTab)) { _ in
            // Switch to profile tab when requested (progress is now in profile)
            selectedTab = 3
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToAITab)) { _ in
            // Switch to AI tab when requested
            selectedTab = 2
        }
        .onChange(of: selectedTab) { _ in
            // Dismiss keyboard when switching tabs
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            // Initialize lives manager with current user
            Task {
                if let userId = dataManager.currentUserId {
                    await livesManager.initializeForUser(userId: userId)
                    print("✅ MainTabView: Lives manager initialized for user: \(userId)")
                } else {
                    print("⚠️ MainTabView: No current user ID available to initialize lives")
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
