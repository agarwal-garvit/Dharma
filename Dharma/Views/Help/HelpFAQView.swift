//
//  HelpFAQView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct HelpFAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingFeedback = false
    
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
                "View detailed analytics"
            ],
            color: .green
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 20) {
                            Image("app-icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Text("Welcome to Dharma")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Your daily companion for learning the Bhagavad Gita")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Features Section
                        VStack(spacing: 20) {
                            Text("App Features")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 16) {
                                ForEach(appFeatures) { feature in
                                    AppFeatureCard(feature: feature)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
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
                                Text("• Lose a life if you get a question wrong")
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
                        .padding(.horizontal)
                        
                        // Contact Support Section
                        VStack(spacing: 16) {
                            Text("Need Help?")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Have questions or feedback? We're here to help!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Contact Support") {
                                showingFeedback = true
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackSubmissionView()
        }
    }
}


#Preview {
    HelpFAQView()
}
