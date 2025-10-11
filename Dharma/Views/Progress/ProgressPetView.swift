//
//  ProgressPetView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ProgressPetView: View {
    @State private var authManager = DharmaAuthManager.shared
    @State private var userMetrics: DBUserMetrics?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var dailyUsageData: [DBDailyUsage] = []
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if let errorMessage = errorMessage {
                    errorView(errorMessage)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Main metrics section
                            mainMetricsSection
                            
                            // Calendar view showing daily usage
                            calendarSection
                            
                            // Detailed stats
                            detailedStatsSection
                            
                            // Recent achievements
                            achievementsSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadUserMetrics()
        }
        .refreshable {
            await refreshMetrics()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading your progress...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Unable to load progress")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                loadUserMetrics()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var mainMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Journey")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Total XP",
                    value: "\(userMetrics?.totalXp ?? 0)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                MetricCard(
                    title: "Current Streak",
                    value: "\(userMetrics?.currentStreak ?? 0) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Lessons Completed",
                    value: "\(userMetrics?.lessonsCompleted ?? 0)",
                    icon: "book.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Study Time",
                    value: "\(userMetrics?.totalStudyTimeMinutes ?? 0) min",
                    icon: "clock.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Calendar")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Simple calendar grid showing the last 30 days
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    // Day headers
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    // Calendar days
                    ForEach(getLast30Days(), id: \.self) { date in
                        CalendarDayView(
                            date: date,
                            isActive: isDateActive(date),
                            isToday: Calendar.current.isDateInToday(date)
                        )
                    }
                }
                
                // Legend
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text("Inactive")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var detailedStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Statistics")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                StatRow(
                    title: "Longest Streak",
                    value: "\(userMetrics?.longestStreak ?? 0) days",
                    icon: "trophy.fill",
                    color: .purple
                )
                
                StatRow(
                    title: "Quiz Average Score",
                    value: String(format: "%.1f%%", userMetrics?.quizAverageScore ?? 0.0),
                    icon: "chart.bar.fill",
                    color: .indigo
                )
                
                StatRow(
                    title: "Total Study Sessions",
                    value: "\(userMetrics?.totalStudyTimeMinutes ?? 0 / 10) sessions",
                    icon: "calendar.badge.clock",
                    color: .teal
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                AchievementRow(
                    title: "First Steps",
                    description: "Completed your first lesson",
                    icon: "book.fill",
                    isUnlocked: (userMetrics?.lessonsCompleted ?? 0) > 0,
                    color: .blue
                )
                
                AchievementRow(
                    title: "Consistent Learner",
                    description: "7-day study streak",
                    icon: "flame.fill",
                    isUnlocked: (userMetrics?.currentStreak ?? 0) >= 7,
                    color: .orange
                )
                
                AchievementRow(
                    title: "Dedicated Student",
                    description: "30-day study streak",
                    icon: "flame.fill",
                    isUnlocked: (userMetrics?.currentStreak ?? 0) >= 30,
                    color: .red
                )
                
                AchievementRow(
                    title: "Knowledge Seeker",
                    description: "Earned 100 XP",
                    icon: "star.fill",
                    isUnlocked: (userMetrics?.totalXp ?? 0) >= 100,
                    color: .yellow
                )
                
                AchievementRow(
                    title: "Quiz Master",
                    description: "90% average quiz score",
                    icon: "chart.bar.fill",
                    isUnlocked: (userMetrics?.quizAverageScore ?? 0) >= 90,
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func loadUserMetrics() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let metrics = authManager.getUserMetrics()
                async let dailyUsage = authManager.getDailyUsage()
                
                let (fetchedMetrics, fetchedDailyUsage) = await (metrics, dailyUsage)
                
                await MainActor.run {
                    self.userMetrics = fetchedMetrics
                    self.dailyUsageData = fetchedDailyUsage
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func refreshMetrics() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            async let metrics = authManager.getUserMetrics()
            async let dailyUsage = authManager.getDailyUsage()
            
            let (fetchedMetrics, fetchedDailyUsage) = await (metrics, dailyUsage)
            
            await MainActor.run {
                self.userMetrics = fetchedMetrics
                self.dailyUsageData = fetchedDailyUsage
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func getLast30Days() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }
        
        return dates.reversed()
    }
    
    private func isDateActive(_ date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return dailyUsageData.contains { usage in
            usage.usageDate == dateString
        }
    }
}

struct MetricCard: View {
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
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct CalendarDayView: View {
    let date: Date
    let isActive: Bool
    let isToday: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isActive ? Color.green : (isToday ? Color.blue.opacity(0.3) : Color.clear))
                .frame(width: 24, height: 24)
            
            Text(dayNumber)
                .font(.caption)
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(isActive ? .white : (isToday ? .blue : .primary))
        }
        .frame(width: 32, height: 32)
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

#Preview {
    ProgressPetView()
}
