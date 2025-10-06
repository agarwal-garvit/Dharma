//
//  ChapterSummaryView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct LessonSummaryView: View {
    let lessonIndex: Int
    let lessonTitle: String
    let lessonSections: [DBLessonSection]
    let onDismiss: () -> Void
    
    @State private var showQuiz = false
    @State private var audioManager = AudioManager.shared
    @State private var lessonStartTime = Date()
    @State private var showingExitConfirmation = false
    
    // Helper methods to extract content from lesson sections
    private var summarySection: DBLessonSection? {
        lessonSections.first { $0.kind == .summary }
    }
    
    private var summaryContent: String {
        guard let section = summarySection,
              let content = section.content,
              let contentString = content["content"]?.value as? String else {
            return "No summary content available for this chapter."
        }
        return contentString
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Lesson header
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lesson \(lessonIndex + 1)")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                            
                            Text(lessonTitle)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        // Summary content
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Summary")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(summaryContent)
                                .font(.title3)
                                .fontWeight(.medium)
                                .lineSpacing(4)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                }
                
                // Test mastery button
                VStack {
                    Button(action: {
                        showQuiz = true
                    }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("Test My Mastery")
                        }
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
            .navigationTitle("Lesson \(lessonIndex + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        showingExitConfirmation = true
                    }
                }
            }
        }
        .onAppear {
            print("LessonSummaryView appeared for Lesson \(lessonIndex)")
        }
        .alert("Exit", isPresented: $showingExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                onDismiss()
            }
        } message: {
            Text("Your progress will be lost. Are you sure you want to exit?")
        }
        .fullScreenCover(isPresented: $showQuiz) {
            QuizView(
                chapterIndex: lessonIndex,
                lessonTitle: lessonTitle,
                lessonStartTime: lessonStartTime,
                onDismiss: { showQuiz = false },
                onComplete: { onDismiss() }
            )
        }
    }
}
#Preview {
    LessonSummaryView(
        lessonIndex: 1,
        lessonTitle: "Sankhya Yoga",
        lessonSections: [],
        onDismiss: {}
    )
}
