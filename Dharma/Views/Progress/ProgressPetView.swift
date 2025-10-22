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
    @State private var loginSessions: [DBUserLoginSession] = []
    @State private var currentMonth = Date()
    
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
        .onReceive(NotificationCenter.default.publisher(for: .streakUpdated)) { _ in
            // Reload metrics when streak is updated (after login)
            print("📊 ProgressPetView received streakUpdated notification - reloading metrics")
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
                    title: "Current Streak",
                    value: "\(userMetrics?.currentStreak ?? 0) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Lessons Complete",
                    value: "\(userMetrics?.lessonsCompleted ?? 0)",
                    icon: "book.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Total Study Time",
                    value: "\(userMetrics?.totalStudyTimeMinutes ?? 0) min",
                    icon: "clock.fill",
                    color: .green
                )
                
                MetricCard(
                    title: "Average Quiz Score",
                    value: String(format: "%.0f%%", userMetrics?.quizAverageScore ?? 0.0),
                    icon: "chart.bar.fill",
                    color: .purple
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
            // Month navigation header
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(monthYearString)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(activeDaysInMonth) active days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(isCurrentMonth ? .gray : .primary)
                }
                .disabled(isCurrentMonth)
            }
            
            VStack(spacing: 12) {
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    // Day headers
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    // Calendar days with proper alignment
                    ForEach(getMonthDays(), id: \.self) { dateWrapper in
                        if let date = dateWrapper.date {
                            CalendarDayView(
                                date: date,
                                isActive: isDateActive(date),
                                isToday: Calendar.current.isDateInToday(date),
                                isCurrentMonth: true
                            )
                        } else {
                            // Empty cell for padding
                            Color.clear
                                .frame(height: 36)
                        }
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
    
    
    private func loadUserMetrics() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let metrics = authManager.getUserMetrics()
                // Fetch more sessions to cover 90+ days even with multiple logins per day
                async let sessions = authManager.getLoginSessions(limit: 500)
                
                let (fetchedMetrics, fetchedSessions) = await (metrics, sessions)
                
                await MainActor.run {
                    self.userMetrics = fetchedMetrics
                    self.loginSessions = fetchedSessions
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
            // Fetch more sessions to cover 90+ days even with multiple logins per day
            async let sessions = authManager.getLoginSessions(limit: 500)
            
            let (fetchedMetrics, fetchedSessions) = await (metrics, sessions)
            
            await MainActor.run {
                self.userMetrics = fetchedMetrics
                self.loginSessions = fetchedSessions
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Calendar Helpers
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var isCurrentMonth: Bool {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month], from: Date())
        let selectedComponents = calendar.dateComponents([.year, .month], from: currentMonth)
        return currentComponents.year == selectedComponents.year && currentComponents.month == selectedComponents.month
    }
    
    private var activeDaysInMonth: Int {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        let isoFormatter = ISO8601DateFormatter()
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        dayFormatter.timeZone = TimeZone.current
        
        // Collect all unique dates with login sessions in this month
        var activeDates = Set<String>()
        for session in loginSessions {
            if let date = isoFormatter.date(from: session.loginTimestamp) {
                let dateString = dayFormatter.string(from: date)
                activeDates.insert(dateString)
            }
        }
        
        // Count how many days in the current month have login sessions
        var count = 0
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                let dateString = dayFormatter.string(from: date)
                if activeDates.contains(dateString) {
                    count += 1
                }
            }
        }
        return count
    }
    
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            // Don't allow navigation to future months
            if value > 0 {
                let now = Date()
                if calendar.compare(newMonth, to: now, toGranularity: .month) == .orderedDescending {
                    return
                }
            }
            currentMonth = newMonth
        }
    }
    
    private func getMonthDays() -> [DateWrapper] {
        let calendar = Calendar.current
        
        // Get the first day of the month
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        // Get the weekday of the first day (1 = Sunday, 7 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        
        // Get the number of days in the month
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count
        
        var days: [DateWrapper] = []
        
        // Add empty cells for days before the month starts
        for _ in 1..<firstWeekday {
            days.append(DateWrapper(date: nil))
        }
        
        // Add all days in the month
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(DateWrapper(date: date))
            }
        }
        
        return days
    }
    
    private func isDateActive(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        dayFormatter.timeZone = TimeZone.current
        let dateString = dayFormatter.string(from: date)
        
        let isoFormatter = ISO8601DateFormatter()
        
        return loginSessions.contains { session in
            if let sessionDate = isoFormatter.date(from: session.loginTimestamp) {
                // Use calendar to ensure we're comparing dates in the user's timezone
                let sessionDateString = dayFormatter.string(from: sessionDate)
                return sessionDateString == dateString
            }
            return false
        }
    }
}

// MARK: - Helper Structures

struct DateWrapper: Hashable {
    let date: Date?
    let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DateWrapper, rhs: DateWrapper) -> Bool {
        lhs.id == rhs.id
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
    let isCurrentMonth: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            if isActive {
                Circle()
                    .fill(Color.green)
                    .frame(width: 32, height: 32)
            }
            
            Text(dayNumber)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundColor(isActive ? .white : .primary)
        }
        .frame(width: 36, height: 36)
    }
}

#Preview {
    ProgressPetView()
}


