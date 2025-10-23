//
//  PrayerView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct PrayerView: View {
    let lesson: DBLesson
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
                    
                    // Reflection text
                    VStack(spacing: 16) {
                        Text("Reflection on Chapter 1")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Divider()
                        
                        // Sanskrit verse from Chapter 1
                        Text("दृष्ट्वेमं स्वजनं कृष्ण युयुत्सुं समुपस्थितम्।\nसीदन्ति मम गात्राणि मुखं च परिशुष्यति॥")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.vertical, 8)
                        
                        Text("dṛṣṭvemaṁ sva-janaṁ kṛṣṇa yuyutsuṁ samupasthitam\nsīdanti mama gātrāṇi mukhaṁ ca pariśuṣyati")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Divider()
                        
                        Text("\"Seeing my own kinsmen arrayed for battle, O Krishna, my limbs give way and my mouth is parched.\"")
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.vertical, 8)
                        
                        Text("— Bhagavad Gita 1.28")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("Chapter 1 presents Arjuna's moral dilemma on the battlefield of Kurukshetra. Faced with fighting his own relatives and teachers, Arjuna experiences deep confusion and sorrow. This sets the stage for Krishna's profound teachings on dharma, duty, and the nature of the self.")
                            .font(.body)
                            .lineSpacing(6)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
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
                lesson: lesson,
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
        lesson: DBLesson(id: UUID(), courseId: UUID(), orderIdx: 2, title: "Sankhya Yoga", imageUrl: nil),
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
