//
//  ProgressPetView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ProgressPetView: View {
    @State private var dataManager = DataManager.shared
    @State private var petHappiness: Double = 0.7
    @State private var petLevel: Int = 3
    @State private var showingPetDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Pet section
                        petSection
                        
                        // Progress stats
                        progressStats
                        
                        // Achievements
                        achievementsSection
                        
                        // Recent activity
                        recentActivitySection
                    }
                    .padding()
                }
            }
            .navigationTitle("My Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPetDetails) {
            PetDetailsView(petLevel: petLevel, happiness: petHappiness)
        }
    }
    
    private var petSection: some View {
        VStack(spacing: 16) {
            Text("Your Spiritual Companion")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Pet display
            Button(action: {
                showingPetDetails = true
            }) {
                VStack(spacing: 12) {
                    // Cow pet
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brown.opacity(0.3), Color.brown.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        // Cow emoji or custom cow drawing
                        Text("🐄")
                            .font(.system(size: 60))
                            .scaleEffect(petHappiness)
                            .animation(.easeInOut(duration: 0.5), value: petHappiness)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Gau Mata")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Level \(petLevel)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Happiness meter
                        HStack {
                            Text("Happiness")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: petHappiness)
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .frame(width: 100)
                            
                            Text("\(Int(petHappiness * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Pet care actions
            petCareActions
        }
    }
    
    private var petCareActions: some View {
        HStack(spacing: 16) {
            Button(action: {
                feedPet()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("Feed")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                playWithPet()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Play")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                meditateWithPet()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.purple)
                    Text("Meditate")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var progressStats: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Journey")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ProgressStatCard(
                    title: "Total XP",
                    value: "\(dataManager.userProgress.totalXP)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                ProgressStatCard(
                    title: "Current Streak",
                    value: "\(dataManager.userProgress.streak) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                ProgressStatCard(
                    title: "Lessons Completed",
                    value: "\(dataManager.userProgress.completedLessons.count)",
                    icon: "book.fill",
                    color: .blue
                )
                
                ProgressStatCard(
                    title: "Study Time",
                    value: "\(getTotalStudyTime()) min",
                    icon: "clock.fill",
                    color: .green
                )
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                AchievementRow(
                    title: "First Steps",
                    description: "Completed your first lesson",
                    icon: "book.fill",
                    isUnlocked: !dataManager.userProgress.completedLessons.isEmpty,
                    color: .blue
                )
                
                AchievementRow(
                    title: "Consistent Learner",
                    description: "7-day study streak",
                    icon: "flame.fill",
                    isUnlocked: dataManager.userProgress.streak >= 7,
                    color: .orange
                )
                
                AchievementRow(
                    title: "Knowledge Seeker",
                    description: "Earned 100 XP",
                    icon: "star.fill",
                    isUnlocked: dataManager.userProgress.totalXP >= 100,
                    color: .yellow
                )
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ActivityRow(
                    title: "Completed Lesson",
                    subtitle: "Karma Yoga Basics",
                    time: "2 hours ago",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                ActivityRow(
                    title: "Earned XP",
                    subtitle: "+25 points",
                    time: "Yesterday",
                    icon: "star.fill",
                    color: .yellow
                )
                
                ActivityRow(
                    title: "Streak Milestone",
                    subtitle: "5 days in a row!",
                    time: "3 days ago",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
    }
    
    private func feedPet() {
        withAnimation {
            petHappiness = min(1.0, petHappiness + 0.1)
        }
        HapticManager.shared.buttonTap()
    }
    
    private func playWithPet() {
        withAnimation {
            petHappiness = min(1.0, petHappiness + 0.15)
        }
        HapticManager.shared.buttonTap()
    }
    
    private func meditateWithPet() {
        withAnimation {
            petHappiness = min(1.0, petHappiness + 0.2)
        }
        HapticManager.shared.buttonTap()
    }
    
    private func getTotalStudyTime() -> Int {
        // TODO: Calculate actual study time from user data
        return dataManager.userProgress.completedLessons.count * 10
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct AchievementRow: View {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color : Color.gray)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color(.systemBackground) : Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct PetDetailsView: View {
    let petLevel: Int
    let happiness: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Pet display
                VStack(spacing: 16) {
                    Text("🐄")
                        .font(.system(size: 100))
                        .scaleEffect(happiness)
                    
                    Text("Gau Mata")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Level \(petLevel) • \(Int(happiness * 100))% Happy")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                // Pet stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pet Statistics")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        PetStatRow(title: "Happiness", value: happiness, color: .green)
                        PetStatRow(title: "Wisdom", value: Double(petLevel) / 10.0, color: .blue)
                        PetStatRow(title: "Spiritual Growth", value: happiness * 0.8, color: .purple)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Pet Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PetStatRow: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: value)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
    }
}

#Preview {
    ProgressPetView()
}
