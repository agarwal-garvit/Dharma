//
//  ChapterSummaryView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct LessonSummaryView: View {
    let lesson: DBLesson
    let lessonTitle: String
    let lessonSections: [DBLessonSection]
    let lessonStartTime: Date
    let onDismiss: () -> Void
    
    @State private var showQuiz = false
    @State private var audioManager = AudioManager.shared
    @State private var showingExitConfirmation = false
    
    // Helper methods to extract content from lesson sections
    private var summarySection: DBLessonSection? {
        lessonSections.first { $0.kind == .summary }
    }
    
    private var summaryContent: String {
        guard let section = summarySection,
              let content = section.content else {
            return "No summary content available for this chapter."
        }
        
        // Handle both JSON structure and plain string content
        if let contentString = content["content"]?.value as? String {
            return contentString
        } else if let wholeContentDict = content as? [String: AnyCodable] {
            // If the entire content is a JSON object, try to parse it
            return ContentParser.parseLessonSummary(from: wholeContentDict.mapValues { $0.value })
        } else {
            return "No summary content available for this chapter."
        }
    }
    
    private var quizSectionId: UUID? {
        lessonSections.first { $0.kind == .quiz }?.id
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Lesson header
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lesson \(lesson.orderIdx)")
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
                            
                            RichContentView(
                                content: summaryContent,
                                font: .title3,
                                lineSpacing: 4,
                                foregroundColor: .primary
                            )
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
            .navigationTitle("Lesson \(lesson.orderIdx)")
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
            print("LessonSummaryView appeared for Lesson \(lesson.title) (ID: \(lesson.id))")
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
            if let quizSectionId = quizSectionId {
                QuizView(
                    sectionId: quizSectionId,
                    lesson: lesson,
                    lessonTitle: lessonTitle,
                    lessonStartTime: lessonStartTime,
                    onDismiss: { showQuiz = false },
                    onComplete: { onDismiss() }
                )
            } else {
                VStack {
                    Text("Quiz not available")
                        .font(.headline)
                    Text("This lesson doesn't have a quiz section.")
                        .foregroundColor(.secondary)
                    Button("Close") {
                        showQuiz = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}
#Preview {
    LessonSummaryView(
        lesson: DBLesson(id: UUID(), courseId: UUID(), orderIdx: 1, title: "Sankhya Yoga", imageUrl: nil),
        lessonTitle: "Sankhya Yoga",
        lessonSections: [],
        lessonStartTime: Date(),
        onDismiss: {}
    )
}
