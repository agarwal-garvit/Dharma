//
//  ProfileView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
internal import Auth

struct ProfileView: View {
    @State private var authManager = DharmaAuthManager.shared
    @State private var isLoading = false
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var isDeletingAccount = false
    @State private var userDisplayName: String?
    @State private var userMetrics: DBUserMetrics?
    @State private var loginSessions: [DBUserLoginSession] = []
    @State private var currentMonth = Date()
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                if isLoading && userMetrics == nil {
                    loadingView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header
                            profileHeader
                            
                            // Progress Metrics Section
                            if let metrics = userMetrics {
                                progressMetricsSection(metrics: metrics)
                            }
                            
                            // Calendar Section
                            calendarSection
                            
                            // Account Actions
                            accountActionsSection
                            
                            // App Information
                            appInfoSection
                            
                            // Delete Account Section
                            deleteAccountSection
                            
                            Spacer(minLength: 50)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Dharma")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? You will be signed out immediately and will not be able to log back in.")
        }
        .onAppear {
            loadUserDisplayName()
            loadUserMetrics()
        }
        .onReceive(NotificationCenter.default.publisher(for: .streakUpdated)) { _ in
            loadUserMetrics()
        }
        .refreshable {
            await refreshMetrics()
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text(getUserInitials())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(getUserDisplayName())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Member since \(getMemberSinceText())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Information")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Terms of Service Button
                Button(action: {
                    if let url = URL(string: "https://docs.google.com/document/d/1LSf_HDzM0Hl9SPF2NNzj4-7LtGyGgfkGEyJ1n3v-eWo/edit?usp=drive_link") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Terms of Service")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Privacy Policy Button
                Button(action: {
                    if let url = URL(string: "https://docs.google.com/document/d/1yrDVbM_ebkaJ6w1_zGTcHqBQcu5XYu_aOsGxdIt3fvk/edit?usp=drive_link") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var accountActionsSection: some View {
            VStack(alignment: .leading, spacing: 16) {
            Text("Account")
                    .font(.headline)
                .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                // Sign Out Button
            Button(action: {
                    showingSignOutAlert = true
            }) {
                HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Sign Out")
                            .foregroundColor(.red)
                        
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            }
                }
                .padding()
                .background(
            RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
    }
    
    private var deleteAccountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            
            VStack(spacing: 12) {
                // Delete Account Button
                Button(action: {
                    showingDeleteAccountAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Delete Account")
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isDeletingAccount)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func getUserDisplayName() -> String {
        // First try to get display name from our custom users table
        if let displayName = userDisplayName, !displayName.isEmpty {
            return displayName
        }
        
        // Fallback to Supabase user metadata or email
        if let user = authManager.user {
            if let fullName = user.userMetadata["full_name"] as? String {
                return fullName
            }
            if let name = user.userMetadata["name"] as? String {
                return name
            }
            if let email = user.email {
                return email.components(separatedBy: "@").first ?? "User"
            }
        }
        return "User"
    }
    
    private func getUserInitials() -> String {
        let displayName = getUserDisplayName()
        let components = displayName.components(separatedBy: " ")
        // Return only the first letter of the first name
        return String(components[0].prefix(1)).uppercased()
    }
    
    private func getMemberSinceText() -> String {
        guard let user = authManager.user else {
            return "Recently"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: user.createdAt)
    }
    
    
    private func loadUserDisplayName() {
        Task {
            let displayName = await authManager.fetchUserDisplayName()
            await MainActor.run {
                self.userDisplayName = displayName
            }
        }
    }
    
    // MARK: - Progress Metrics Section
    
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
    
    private func progressMetricsSection(metrics: DBUserMetrics) -> some View {
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
                    value: "\(metrics.currentStreak) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Lessons Complete",
                    value: "\(metrics.lessonsCompleted)",
                    icon: "book.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Total Study Time",
                    value: "\(metrics.totalStudyTimeMinutes) min",
                    icon: "clock.fill",
                    color: .green
                )
                
                MetricCard(
                    title: "Average Quiz Score",
                    value: String(format: "%.0f%%", metrics.quizAverageScore),
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
    
    // MARK: - Calendar Section
    
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
                    
                    // Calendar days
                    ForEach(getMonthDays(), id: \.self) { dateWrapper in
                        if let date = dateWrapper.date {
                            CalendarDayView(
                                date: date,
                                isActive: isDateActive(date),
                                isToday: Calendar.current.isDateInToday(date),
                                isCurrentMonth: true
                            )
                        } else {
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
    
    // MARK: - Data Loading
    
    private func loadUserMetrics() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let metrics = authManager.getUserMetrics()
                async let sessions = authManager.getLoginSessions(limit: 500)
                
                let (fetchedMetrics, fetchedSessions) = await (metrics, sessions)
                
                await MainActor.run {
                    self.loginSessions = fetchedSessions
                    
                    let calculatedStreak = self.calculateCurrentStreak()
                    
                    if var updatedMetrics = fetchedMetrics {
                        self.userMetrics = DBUserMetrics(
                            totalXp: updatedMetrics.totalXp,
                            currentStreak: calculatedStreak,
                            longestStreak: updatedMetrics.longestStreak,
                            lessonsCompleted: updatedMetrics.lessonsCompleted,
                            totalStudyTimeMinutes: updatedMetrics.totalStudyTimeMinutes,
                            quizAverageScore: updatedMetrics.quizAverageScore
                        )
                    } else {
                        self.userMetrics = fetchedMetrics
                    }
                    
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
            async let sessions = authManager.getLoginSessions(limit: 500)
            
            let (fetchedMetrics, fetchedSessions) = await (metrics, sessions)
            
            await MainActor.run {
                self.loginSessions = fetchedSessions
                
                let calculatedStreak = self.calculateCurrentStreak()
                
                if var updatedMetrics = fetchedMetrics {
                    self.userMetrics = DBUserMetrics(
                        totalXp: updatedMetrics.totalXp,
                        currentStreak: calculatedStreak,
                        longestStreak: updatedMetrics.longestStreak,
                        lessonsCompleted: updatedMetrics.lessonsCompleted,
                        totalStudyTimeMinutes: updatedMetrics.totalStudyTimeMinutes,
                        quizAverageScore: updatedMetrics.quizAverageScore
                    )
                } else {
                    self.userMetrics = fetchedMetrics
                }
                
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
        
        var activeDates = Set<String>()
        for session in loginSessions {
            if let date = isoFormatter.date(from: session.loginTimestamp) {
                let originalTimezone = session.userTimezone ?? TimeZone.current.identifier
                let sessionDayFormatter = DateFormatter()
                sessionDayFormatter.dateFormat = "yyyy-MM-dd"
                sessionDayFormatter.timeZone = TimeZone(identifier: originalTimezone)
                let dateString = sessionDayFormatter.string(from: date)
                activeDates.insert(dateString)
            }
        }
        
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
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count
        
        var days: [DateWrapper] = []
        
        for _ in 1..<firstWeekday {
            days.append(DateWrapper(date: nil))
        }
        
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
                let originalTimezone = session.userTimezone ?? TimeZone.current.identifier
                let sessionDayFormatter = DateFormatter()
                sessionDayFormatter.dateFormat = "yyyy-MM-dd"
                sessionDayFormatter.timeZone = TimeZone(identifier: originalTimezone)
                let sessionDateString = sessionDayFormatter.string(from: sessionDate)
                return sessionDateString == dateString
            }
            return false
        }
    }
    
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        dayFormatter.timeZone = TimeZone.current
        
        var currentDate = calendar.startOfDay(for: Date())
        var streak = 0
        
        if isDateActive(currentDate) {
            streak = 1
            
            while true {
                guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                
                if isDateActive(previousDate) {
                    streak += 1
                    currentDate = previousDate
                } else {
                    break
                }
            }
        }
        
        return streak
    }
    
    private func signOut() {
        isLoading = true
        
        Task {
            do {
                try await authManager.signOut()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("Sign out failed: \(error)")
                }
            }
        }
    }
    
    private func deleteAccount() {
        isDeletingAccount = true
        
        Task {
            do {
                try await authManager.deleteAccount()
                await MainActor.run {
                    isDeletingAccount = false
                }
            } catch {
                await MainActor.run {
                    isDeletingAccount = false
                    print("Account deletion failed: \(error)")
                }
            }
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
    ProfileView()
}
