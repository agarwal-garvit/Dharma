//
//  PrayerView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct PrayerView: View {
    let chapterIndex: Int
    let lessonTitle: String
    let score: Int
    let totalQuestions: Int
    let timeElapsed: TimeInterval
    let lessonStartTime: Date
    let questionsAnswered: [String: Any]?
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var audioManager = AudioManager.shared
    @State private var showResults = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Gau Mata logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text("🐄")
                            .font(.system(size: 50))
                    }
                    
                    // Prayer content
                    VStack(spacing: 16) {
                        Text("Closing Prayer")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(lessonTitle)
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    // Prayer text
                    VStack(spacing: 16) {
                        Text("Om Namo Bhagavate Vasudevaya")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Salutations to Lord Krishna, the son of Vasudeva")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Divider()
                        
                        Text("Prayer content will be loaded from the database...")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.secondary)
                            .italic()
                            .multilineTextAlignment(.center)
                        
                        Divider()
                        
                        Text("Closing prayer will be loaded from the database...")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.secondary)
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            
            // Done button
            VStack {
                Button(action: {
                    showResults = true  // Open ResultsView
                }) {
                    Text("Om Shanti, Shanti, Shanti")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .fullScreenCover(isPresented: $showResults) {
            ResultsView(
                chapterIndex: chapterIndex,
                lessonTitle: lessonTitle,
                score: score,
                totalQuestions: totalQuestions,
                timeElapsed: timeElapsed,
                lessonStartTime: lessonStartTime,
                questionsAnswered: questionsAnswered,
                onDismiss: { showResults = false },
                onComplete: onComplete  // Direct pass-through, no complex logic
            )
        }
    }
    
}

#Preview {
    PrayerView(
        chapterIndex: 2,
        lessonTitle: "Sankhya Yoga",
        score: 4,
        totalQuestions: 5,
        timeElapsed: 180,
        lessonStartTime: Date(),
        questionsAnswered: [:],
        onDismiss: {},
        onComplete: {}
    )
}
