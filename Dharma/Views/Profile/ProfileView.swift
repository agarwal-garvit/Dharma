//
//  ProfileView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
internal import Auth

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authManager = DharmaAuthManager.shared
    @State private var isLoading = false
    @State private var showingSignOutAlert = false
    @State private var userStats: UserStats?
    @State private var completedLessonsCount = 0
    @State private var isLoadingStats = true
    @State private var userDisplayName: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader
                    
                    // User Stats Section
                    userStatsSection
                    
                    // Account Actions
                    accountActionsSection
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onAppear {
            loadUserStats()
            loadUserDisplayName()
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
                
                if let email = authManager.user?.email {
                    Text(email)
                    .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
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
    
    private var userStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Total XP",
                    value: isLoadingStats ? "..." : "\(userStats?.xp_total ?? 0)",
                    icon: "star.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Current Streak",
                    value: isLoadingStats ? "..." : "\(userStats?.streak_count ?? 0) days",
                    icon: "flame.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Lessons Completed",
                    value: isLoadingStats ? "..." : "\(completedLessonsCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Longest Streak",
                    value: isLoadingStats ? "..." : "\(userStats?.longest_streak ?? 0) days",
                    icon: "trophy.fill",
                    color: .blue
                )
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
                // Settings Button
            Button(action: {
                    // TODO: Navigate to settings
            }) {
                HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Settings")
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
    
    private func loadUserStats() {
        isLoadingStats = true
        
        Task {
            // Fetch user stats and completed lessons count
            let stats = await authManager.fetchUserStats()
            let completedCount = await authManager.getCompletedLessonsCount()
            
            await MainActor.run {
                self.userStats = stats
                self.completedLessonsCount = completedCount
                self.isLoadingStats = false
            }
        }
    }
    
    private func loadUserDisplayName() {
        Task {
            let displayName = await authManager.fetchUserDisplayName()
            await MainActor.run {
                self.userDisplayName = displayName
            }
        }
    }
    
    private func signOut() {
        isLoading = true
        
        Task {
            do {
                try await authManager.signOut()
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("Sign out failed: \(error)")
                }
            }
        }
    }
}

struct StatCard: View {
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

#Preview {
    ProfileView()
}
