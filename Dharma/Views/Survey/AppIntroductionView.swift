//
//  AppIntroductionView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct AppIntroductionView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let appFeatures = [
        AppFeature(
            icon: "book.closed.fill",
            title: "Learn",
            points: [
                "Structured lessons on Bhagavad Gita",
                "Interactive quizzes and exercises",
                "Progressive learning path"
            ],
            color: .orange
        ),
        AppFeature(
            icon: "calendar",
            title: "Daily",
            points: [
                "Daily verses and reflections",
                "Study reminders and tracking",
                "Consistent spiritual practice"
            ],
            color: .blue
        ),
        AppFeature(
            icon: "message.circle.fill",
            title: "AI Chatbot",
            points: [
                "Ask questions about Hinduism",
                "Get verse explanations",
                "Discuss spiritual concepts"
            ],
            color: .indigo
        ),
        AppFeature(
            icon: "chart.line.uptrend.xyaxis",
            title: "Progress",
            points: [
                "Track your learning journey",
                "View detailed analytics",
                "Achievement milestones"
            ],
            color: .green
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 20) {
                        Text("Features of Dharma")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Features List
                            VStack(spacing: 16) {
                                ForEach(appFeatures) { feature in
                                    AppFeatureCard(feature: feature)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Lives System Section
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                    
                                    Text("Lives System")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("• Earn lives to participate in quizzes")
                                    Text("• Lives regenerate over time")
                                    Text("• Encourages thoughtful learning")
                                }
                                .font(.body)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 24)
                            
                            // Bottom spacing for button
                            Spacer(minLength: 120)
                        }
                    }
                    
                    // Start Button (Fixed at bottom)
                    VStack(spacing: 8) {
                        Button("Start Your Journey") {
                            // Notify that we're ready to show main app
                            NotificationCenter.default.post(name: .surveyCompleted, object: nil)
                            dismiss()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                ThemeManager.appBackground.opacity(0.95),
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
        }
    }
}

struct AppFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let points: [String]
    let color: Color
}

struct AppFeatureCard: View {
    let feature: AppFeature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundColor(feature.color)
                    .frame(width: 30, height: 30)
                
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(feature.points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(feature.color)
                            .fontWeight(.bold)
                        
                        Text(point)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    AppIntroductionView()
}