//
//  ResultsView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ResultsView: View {
    let lesson: DBLesson
    let lessonTitle: String
    let score: Int
    let totalQuestions: Int
    let timeElapsed: TimeInterval
    let lessonStartTime: Date
    let questionsAnswered: [String: Any]?
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var showChatbot = false
    @State private var dataManager = DataManager.shared
    
    private var percentage: Int {
        let percentage = Int((Double(score) / Double(totalQuestions)) * 100)
        print("📊 ResultsView: Score = \(score)/\(totalQuestions) = \(percentage)%")
        return percentage
    }
    
    private var timeString: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        print("⏱️ ResultsView: timeElapsed = \(timeElapsed) seconds, formatted as \(minutes):\(String(format: "%02d", seconds))")
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("Lesson Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(lessonTitle)
                        .font(.title2)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
                
                // Results summary
                VStack(spacing: 20) {
                    // Score card
                    VStack(spacing: 12) {
                        Text("Your Score")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(score)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Correct")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("/")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            VStack {
                                Text("\(totalQuestions)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("\(percentage)%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(percentage >= 80 ? .green : percentage >= 60 ? .orange : .red)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Time card
                    VStack(spacing: 8) {
                        Text("Time Taken")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(timeString)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                }
                
                // Performance message
                VStack(spacing: 8) {
                    Text(getPerformanceMessage())
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(getEncouragementMessage())
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(percentage >= 80 ? Color.green.opacity(0.1) : percentage >= 60 ? Color.orange.opacity(0.1) : Color.red.opacity(0.1))
                )
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showChatbot = true
                    }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("Ask AI")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Complete the lesson and then close
                        completeLesson()
                        onComplete()
                    }) {
                        Text("Close lesson")
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
                .padding(.horizontal)
            }
            .padding()
        .sheet(isPresented: $showChatbot) {
            ChatbotView()
        }
    }
    
    private func completeLesson() {
        Task {
            print("📝 Completing lesson: \(lesson.title) (ID: \(lesson.id), Course: \(lesson.courseId))")
            
            // Record comprehensive lesson completion
            if let userId = dataManager.currentUserId {
                do {
                    let _ = try await dataManager.recordLessonCompletion(
                        userId: userId,
                        lessonId: lesson.id,
                        score: score,
                        totalQuestions: totalQuestions,
                        timeElapsedSeconds: Int(timeElapsed),
                        questionsAnswered: questionsAnswered ?? [:],
                        startedAt: lessonStartTime,
                        completedAt: Date()
                    )
                    print("✅ Comprehensive lesson completion recorded for \(lesson.title)")
                } catch {
                    print("❌ Failed to record lesson completion: \(error)")
                }
            }
            
            // Also update the existing lesson completion system
            await dataManager.completeLesson(lesson.id)
            print("✅ Lesson \(lesson.title) marked as completed")
        }
    }
    
    private func getPerformanceMessage() -> String {
        if percentage >= 90 {
            return "Excellent! 🌟"
        } else if percentage >= 80 {
            return "Great Job! 👏"
        } else if percentage >= 70 {
            return "Good Work! 👍"
        } else if percentage >= 60 {
            return "Not Bad! 💪"
        } else {
            return "Keep Learning! 📚"
        }
    }
    
    private func getEncouragementMessage() -> String {
        if percentage >= 80 {
            return "You have a strong understanding of this chapter. The teachings are becoming part of your wisdom."
        } else if percentage >= 60 {
            return "You're making good progress. Consider reviewing the key concepts to deepen your understanding."
        } else {
            return "Learning is a journey. Take time to reflect on the teachings and try the lesson again when you're ready."
        }
    }
}

#Preview {
    ResultsView(
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
