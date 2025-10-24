//
//  ChapterSummaryView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

// MARK: - Content Item Model

enum ContentItem: Identifiable {
    case text(String)
    case image(String)
    
    var id: String {
        switch self {
        case .text(let content):
            return "text_\(content.prefix(20))"
        case .image(let url):
            return "image_\(url)"
        }
    }
}

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
              let content = section.content,
              let contentString = content["content"]?.value as? String else {
            return "No summary content available for this chapter."
        }
        return contentString
    }
    
    private var quizSectionId: UUID? {
        lessonSections.first { $0.kind == .quiz }?.id
    }
    
    // MARK: - Content Parsing
    
    private func parseContent(_ content: String) -> [ContentItem] {
        var items: [ContentItem] = []
        var currentText = ""
        var i = content.startIndex
        
        while i < content.endIndex {
            // Look for opening bracket
            if content[i] == "[" {
                // Add any accumulated text as a text item
                if !currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    items.append(.text(currentText))
                    currentText = ""
                }
                
                // Find closing bracket
                var j = content.index(after: i)
                while j < content.endIndex && content[j] != "]" {
                    j = content.index(after: j)
                }
                
                if j < content.endIndex {
                    // Extract URL from brackets
                    let startIndex = content.index(after: i)
                    let urlString = String(content[startIndex..<j])
                    
                    // Validate URL and add as image item
                    if !urlString.isEmpty && (urlString.hasPrefix("http://") || urlString.hasPrefix("https://")) {
                        items.append(.image(urlString))
                    }
                    
                    // Move past the closing bracket
                    i = content.index(after: j)
                } else {
                    // No closing bracket found, treat as regular text
                    currentText.append(content[i])
                    i = content.index(after: i)
                }
            } else {
                currentText.append(content[i])
                i = content.index(after: i)
            }
        }
        
        // Add any remaining text
        if !currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            items.append(.text(currentText))
        }
        
        return items
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(lessonTitle)
                            .font(.title2)
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                    }
                    
                    // Summary content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Chapter Overview")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // Render parsed content (text and images)
                        let contentItems = parseContent(summaryContent)
                        ForEach(contentItems) { item in
                            switch item {
                            case .text(let text):
                                Text(text)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .foregroundColor(.primary)
                                
                            case .image(let urlString):
                                CachedAsyncImage(url: URL(string: urlString)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(12)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 200)
                                        .cornerRadius(12)
                                        .overlay(
                                            ProgressView()
                                                .tint(.orange)
                                        )
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    // Test mastery button - now inside ScrollView
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
                    .padding(.top, 16)
                }
                .padding()
            }
            .navigationTitle("Summary")
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
    // Create test lesson sections with mixed content
    let testContent = [
        "content": AnyCodable("This is the chapter introduction with some text.\n\n[https://example.com/test-image1.jpg]\n\nThis is more explanation text that comes after the image.\n\n[https://example.com/test-image2.jpg]\n\nFinal thoughts on the chapter.")
    ]
    
    let testSection = DBLessonSection(
        id: UUID(),
        lessonId: UUID(),
        kind: .summary,
        orderIdx: 1,
        content: testContent
    )
    
    return LessonSummaryView(
        lesson: DBLesson(id: UUID(), courseId: UUID(), orderIdx: 1, title: "Sankhya Yoga", imageUrl: nil),
        lessonTitle: "Sankhya Yoga",
        lessonSections: [testSection],
        lessonStartTime: Date(),
        onDismiss: {}
    )
}
