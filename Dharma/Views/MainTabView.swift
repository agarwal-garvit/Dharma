//
//  MainTabView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LearnView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Learn")
                }
                .tag(0)
            
            BhagavadGitaView()
                .tabItem {
                    Image(systemName: "scroll.fill")
                    Text("Gita")
                }
                .tag(1)
            
            ProgressPetView()
                .tabItem {
                    Image(systemName: "pawprint.fill")
                    Text("Progress")
                }
                .tag(2)
            
            LeaderboardView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Leaderboard")
                }
                .tag(3)
            
            ChatbotView()
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
