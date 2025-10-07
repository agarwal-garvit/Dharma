//
//  SignInView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import GoogleSignIn

struct SignInView: View {
    @State private var isEmailLoading = false
    @State private var isGoogleLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    
    private let authManager = DharmaAuthManager.shared
    
    private var loadingMessage: String {
        if isEmailLoading {
            return isSignUpMode ? "Creating your account..." : "Signing you in..."
        } else if isGoogleLoading {
            return "Connecting with Google..."
        }
        return ""
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.1),
                        Color.orange.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Logo and Title
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 8) {
                            Text("Welcome to Dharma")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Your daily companion for learning the Bhagavad Gita")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    // Sign In Section
                    VStack(spacing: 24) {
                        Text(isSignUpMode ? "Create your account" : "Sign in to continue your spiritual journey")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Email/Password Form
                        VStack(spacing: 16) {
                            if isSignUpMode {
                                TextField("Display Name", text: $displayName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                            }
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal, 32)
                        
                        // Email Sign In/Up Button
                        Button(action: isSignUpMode ? signUpWithEmail : signInWithEmail) {
                            HStack(spacing: 12) {
                                if isEmailLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: isSignUpMode ? "person.badge.plus" : "envelope")
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                }
                                
                                Text(isSignUpMode ? "Create Account" : "Sign In with Email")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isEmailLoading ? Color.orange.opacity(0.7) : Color.orange)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isEmailLoading || isGoogleLoading || email.isEmpty || password.isEmpty)
                        .padding(.horizontal, 32)
                        
                        // Toggle Sign Up/Sign In
                        Button(action: {
                            withAnimation {
                                isSignUpMode.toggle()
                                errorMessage = nil
                                isEmailLoading = false
                                isGoogleLoading = false
                            }
                        }) {
                            Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.horizontal, 32)
                        
                        // Google Sign In Button
                        Button(action: signInWithGoogle) {
                            HStack(spacing: 12) {
                                if isGoogleLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    // Google logo - fallback to system image if asset not available
                                    if let googleLogo = UIImage(named: "google_logo") {
                                        Image(uiImage: googleLogo)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    } else {
                                        Image(systemName: "globe")
                                            .foregroundColor(.white)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                
                                Text("Continue with Google")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isGoogleLoading ? Color.blue.opacity(0.7) : Color.blue)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isEmailLoading || isGoogleLoading)
                        .padding(.horizontal, 32)
                        
                        // Loading Status Message
                        if isEmailLoading || isGoogleLoading {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                        .scaleEffect(0.8)
                                    
                                    Text(loadingMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                if isGoogleLoading {
                                    Text("This may take a moment for first-time users...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .transition(.opacity)
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                        
                        // Terms and Privacy
                        VStack(spacing: 8) {
                            Text("By continuing, you agree to our")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Button("Terms of Service") {
                                    // TODO: Open terms of service
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                                
                                Text("and")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Privacy Policy") {
                                    // TODO: Open privacy policy
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .alert("Sign In Error", isPresented: $showingError) {
            Button("OK") {
                showingError = false
            }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func signInWithEmail() {
        isEmailLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signInWithEmail(email: email, password: password)
                // Authentication success is handled by the auth state listener
            } catch {
                await MainActor.run {
                    isEmailLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func signUpWithEmail() {
        isEmailLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signUpWithEmail(
                    email: email, 
                    password: password, 
                    displayName: displayName.isEmpty ? nil : displayName
                )
                // Authentication success is handled by the auth state listener
            } catch {
                await MainActor.run {
                    isEmailLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func signInWithGoogle() {
        isGoogleLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signInWithGoogle()
                // Authentication success is handled by the auth state listener
            } catch {
                await MainActor.run {
                    isGoogleLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

// MARK: - Google Logo Asset
// Note: You'll need to add a Google logo image asset named "google_logo" to your Assets.xcassets
// You can download it from: https://developers.google.com/identity/branding-guidelines

#Preview {
    SignInView()
}
