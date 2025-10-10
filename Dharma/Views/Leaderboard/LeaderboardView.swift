//
//  LeaderboardView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var selectedTimeframe: Timeframe = .weekly
    @State private var showingComingSoon = true
    
    enum Timeframe: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if showingComingSoon {
                        comingSoonView
                    } else {
                        leaderboardContent
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !showingComingSoon {
                        Menu {
                            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                Button(timeframe.rawValue) {
                                    selectedTimeframe = timeframe
                                }
                            }
                        } label: {
                            Text(selectedTimeframe.rawValue)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }
    
    private var comingSoonView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
            }
            
            // Coming Soon text
            Text("Coming Soon")
                .font(.title2)
                .foregroundColor(.orange)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
    
    private var leaderboardContent: some View {
        VStack(spacing: 0) {
            // Timeframe selector
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Leaderboard list
            List {
                ForEach(0..<10) { index in
                    LeaderboardRow(
                        rank: index + 1,
                        name: "User \(index + 1)",
                        xp: 1000 - (index * 50),
                        streak: 30 - index,
                        isCurrentUser: index == 2
                    )
                }
            }
        }
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let name: String
    let xp: Int
    let streak: Int
    let isCurrentUser: Bool
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .secondary
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "\(rank)"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                Circle()
                    .fill(isCurrentUser ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                if rank <= 3 {
                    Image(systemName: rankIcon)
                        .foregroundColor(rankColor)
                        .font(.title3)
                } else {
                    Text("\(rank)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(rankColor)
                }
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(isCurrentUser ? .orange : .primary)
                    
                    if isCurrentUser {
                        Text("You")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.orange.opacity(0.2))
                            )
                            .foregroundColor(.orange)
                    }
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(xp) XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("\(streak) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(
            isCurrentUser ? Color.orange.opacity(0.05) : Color.clear
        )
    }
}

#Preview {
    LeaderboardView()
}
