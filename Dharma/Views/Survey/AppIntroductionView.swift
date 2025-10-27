//
//  AppIntroductionView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct AppIntroductionView: View {
    @State private var showingOnboarding = false
    
    private let features = [
        FeatureInfo(
            icon: "book.closed.fill",
            title: "Learn",
            description: "Explore the Bhagavad Gita through structured lessons, quizzes, and interactive content designed to deepen your understanding of this sacred text.",
            color: .orange
        ),
        FeatureInfo(
            icon: "calendar",
            title: "Daily",
            description: "Build a consistent practice with daily verses, reflections, and reminders. Track your progress and maintain your spiritual journey.",
            color: .blue
        ),
        FeatureInfo(
            icon: "chart.line.uptrend.xyaxis",
            title: "Progress",
            description: "Monitor your learning journey with detailed analytics, streak tracking, and achievement milestones to stay motivated.",
            color: .green
        ),
        FeatureInfo(
            icon: "person.circle",
            title: "Profile",
            description: "Manage your account, view your achievements, and customize your learning experience to match your spiritual goals.",
            color: .purple
        ),
        FeatureInfo(
            icon: "message.circle.fill",
            title: "AI Chatbot",
            description: "Ask questions about Hinduism, get explanations of verses, or discuss spiritual concepts with our AI companion.",
            color: .indigo
        ),
        FeatureInfo(
            icon: "flame.fill",
            title: "Lives System",
            description: "Earn and manage lives to participate in quizzes and learning activities. Lives regenerate over time to encourage consistent practice.",
            color: .red
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            ThemeManager.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Welcome to Dharma")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your spiritual journey begins here")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                .padding(.horizontal)
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Introduction Text
                        VStack(spacing: 16) {
                            Text("Discover the timeless wisdom of the Bhagavad Gita through an immersive learning experience designed for the modern seeker.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text("Here's what you can explore:")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        
                        // Features List
                        VStack(spacing: 20) {
                            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                                FeatureCardView(feature: feature, index: index)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bottom Spacing for Button
                        Spacer(minLength: 100)
                    }
                }
                
                // Start App Button (Fixed at bottom)
                VStack(spacing: 12) {
                    Button("Start Your Journey") {
                        showingOnboarding = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    
                    Text("Begin exploring Dharma's features")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                .background(
                    // Gradient overlay to fade content behind button
                    LinearGradient(
                        colors: [
                            Color.clear,
                            ThemeManager.appBackground.opacity(0.8),
                            ThemeManager.appBackground
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    .allowsHitTesting(false)
                )
            }
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
        }
    }
}

struct FeatureInfo {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct FeatureCardView: View {
    let feature: FeatureInfo
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 24))
                    .foregroundColor(feature.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(feature.color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    AppIntroductionView()
}
