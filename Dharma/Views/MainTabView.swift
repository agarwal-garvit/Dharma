//
//  MainTabView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

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
            
            SacredTextView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "scroll.fill")
                    Text("Sacred Texts")
                }
                .tag(1)
            
            ProgressPetView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "pawprint.fill")
                    Text("Progress")
                }
                .tag(2)
            
            LeaderboardView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Leaderboard")
                }
                .tag(3)
            
            ChatbotView()
                .background(ThemeManager.appBackground)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(4)
        }
        .accentColor(.orange)
    }
}

#Preview {
    MainTabView()
}
