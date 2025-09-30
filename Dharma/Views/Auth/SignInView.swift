//
//  SignInView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import GoogleSignIn

struct SignInView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    
    private let authManager = DharmaAuthManager.shared
    
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
                                if isLoading {
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
                            .background(Color.orange)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding(.horizontal, 32)
                        
                        // Toggle Sign Up/Sign In
                        Button(action: {
                            withAnimation {
                                isSignUpMode.toggle()
                                errorMessage = nil
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
                                if isLoading {
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
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 32)
                        
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
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signInWithEmail(email: email, password: password)
                // Authentication success is handled by the auth state listener
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func signUpWithEmail() {
        isLoading = true
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
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signInWithGoogle()
                // Authentication success is handled by the auth state listener
            } catch {
                await MainActor.run {
                    isLoading = false
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
