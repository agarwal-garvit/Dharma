//
//  MainTabView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import Combine

struct MainTabView: View {
    @State private var selectedTab = 0
    
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
            LearnView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Learn")
                }
                .tag(0)
            
            DailyView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("Daily")
                }
                .tag(1)
            
            ProgressPetView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .tag(2)
            
            SacredTextView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "scroll.fill")
                    Text("Texts")
                }
                .tag(3)
            
            ChatbotView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("AI")
                }
                .tag(4)
        }
        .accentColor(.orange)
        .onReceive(NotificationCenter.default.publisher(for: .switchToProgressTab)) { _ in
            // Switch to progress tab when requested
            selectedTab = 2
        }
    }
}

#Preview {
    MainTabView()
}
