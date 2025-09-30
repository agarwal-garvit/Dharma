//
//  ProfileView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var dataManager = DataManager.shared
    @State private var showingSettings = false
    @State private var showingAchievements = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader
                    
                    // Stats overview
                    statsOverview
                    
                    // Progress sections
                    progressSections
                    
                    // Settings and actions
                    settingsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView()
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 4) {
                Text("Dharma Student")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Learning the Bhagavad Gita")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var statsOverview: some View {
        VStack(spacing: 16) {
            Text("Your Progress")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Streak",
                    value: "\(dataManager.userProgress.streak)",
                    subtitle: "days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "XP",
                    value: "\(dataManager.userProgress.totalXP)",
                    subtitle: "points",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Lessons",
                    value: "\(dataManager.userProgress.completedLessons.count)",
                    subtitle: "completed",
                    icon: "book.fill",
                    color: .blue
                )
            }
        }
    }
    
    private var progressSections: some View {
        VStack(spacing: 20) {
            // Learning progress
            VStack(alignment: .leading, spacing: 16) {
                Text("Learning Progress")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    ProgressRow(
                        title: "Lessons Completed",
                        completed: dataManager.userProgress.completedLessons.count,
                        total: dataManager.lessons.count,
                        color: .blue
                    )
                    
                    ProgressRow(
                        title: "Units Completed",
                        completed: dataManager.userProgress.completedUnits.count,
                        total: dataManager.chapters.count,
                        color: .green
                    )
                    
                    ProgressRow(
                        title: "Review Items",
                        completed: dataManager.reviewItems.count,
                        total: dataManager.reviewItems.count,
                        color: .purple
                    )
                }
            }
            
            // Study habits
            VStack(alignment: .leading, spacing: 16) {
                Text("Study Habits")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    HabitRow(
                        title: "Daily Goal",
                        value: dataManager.userPreferences.studyGoal.displayName,
                        icon: "target"
                    )
                    
                    HabitRow(
                        title: "Study Time",
                        value: formatStudyTime(dataManager.userPreferences.studyTime),
                        icon: "clock"
                    )
                    
                    HabitRow(
                        title: "Script Display",
                        value: dataManager.userPreferences.scriptDisplay.displayName,
                        icon: "textformat"
                    )
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingAchievements = true
            }) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("Achievements")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                showingSettings = true
            }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                    Text("Settings")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                // Export progress
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                    Text("Export Progress")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func formatStudyTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct ProgressRow: View {
    let title: String
    let completed: Int
    let total: Int
    let color: Color
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(completed)/\(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct HabitRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section("Study Preferences") {
                    Picker("Study Goal", selection: $dataManager.userPreferences.studyGoal) {
                        ForEach(StudyGoal.allCases, id: \.self) { goal in
                            Text(goal.displayName).tag(goal)
                        }
                    }
                    
                    Picker("Script Display", selection: $dataManager.userPreferences.scriptDisplay) {
                        ForEach(ScriptDisplay.allCases, id: \.self) { script in
                            Text(script.displayName).tag(script)
                        }
                    }
                    
                    DatePicker("Study Time", selection: $dataManager.userPreferences.studyTime, displayedComponents: .hourAndMinute)
                }
                
                Section("Audio & Haptics") {
                    Toggle("Sound Effects", isOn: $dataManager.userPreferences.soundEnabled)
                    Toggle("Haptic Feedback", isOn: $dataManager.userPreferences.hapticsEnabled)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Playback Speed")
                        Slider(value: $dataManager.userPreferences.playbackSpeed, in: 0.5...2.0, step: 0.1)
                        Text("\(String(format: "%.1f", dataManager.userPreferences.playbackSpeed))x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Notifications") {
                    Toggle("Daily Reminders", isOn: $dataManager.userPreferences.notificationsEnabled)
                }
                
                Section("Display") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Font Size")
                        Slider(value: $dataManager.userPreferences.fontSize, in: 0.8...1.4, step: 0.1)
                        Text("\(String(format: "%.1f", dataManager.userPreferences.fontSize))x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data") {
                    Button("Reset Progress") {
                        // Reset progress
                    }
                    .foregroundColor(.red)
                    
                    Button("Export Data") {
                        // Export data
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dataManager.saveUserData()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dataManager = DataManager.shared
    
    private var achievements: [Achievement] {
        [
            Achievement(
                id: "first_lesson",
                title: "First Steps",
                description: "Complete your first lesson",
                icon: "book.fill",
                isUnlocked: !dataManager.userProgress.completedLessons.isEmpty,
                color: .blue
            ),
            Achievement(
                id: "week_streak",
                title: "Consistent Learner",
                description: "Maintain a 7-day streak",
                icon: "flame.fill",
                isUnlocked: dataManager.userProgress.streak >= 7,
                color: .orange
            ),
            Achievement(
                id: "hundred_xp",
                title: "Knowledge Seeker",
                description: "Earn 100 XP",
                icon: "star.fill",
                isUnlocked: dataManager.userProgress.totalXP >= 100,
                color: .yellow
            ),
            Achievement(
                id: "first_unit",
                title: "Chapter Master",
                description: "Complete your first unit",
                icon: "folder.fill",
                isUnlocked: !dataManager.userProgress.completedUnits.isEmpty,
                color: .green
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
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

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let color: Color
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color : Color.gray)
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .foregroundColor(.white)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
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
                .fill(achievement.isUnlocked ? Color(.systemBackground) : Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    ProfileView()
}
