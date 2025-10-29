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
    @State private var showingDeleteAccountAlert = false
    @State private var isDeletingAccount = false
    @State private var userDisplayName: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader
                        
                        // Account Actions
                        accountActionsSection
                        
                        // App Information
                        appInfoSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
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
                
                // About Button
                Button(action: {
                    // TODO: Navigate to about page
                }) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Text("About Dharma")
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
    
    private func deleteAccount() {
        isDeletingAccount = true
        
        Task {
            do {
                try await authManager.deleteAccount()
                await MainActor.run {
                    isDeletingAccount = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isDeletingAccount = false
                    print("Account deletion failed: \(error)")
                    // You could add an error alert here if needed
                }
            }
        }
    }
}


#Preview {
    ProfileView()
}
