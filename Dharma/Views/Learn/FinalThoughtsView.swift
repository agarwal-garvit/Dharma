//
//  FinalThoughtsView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

// MARK: - Final Thoughts Content Model

struct FinalThoughtsContent {
    let analysis: String
    let keyTerms: [String: String]
    
    init(from content: [String: AnyCodable]?) {
        // Handle both simple and complex content structures
        if let content = content {
            // Try to get analysis from the new structure
            if let analysisValue = content["analysis"]?.value as? String {
                self.analysis = analysisValue
            } else if let titleValue = content["title"]?.value as? String,
                      let contentValue = content["content"]?.value as? String {
                // Fallback to simple structure: combine title and content
                self.analysis = "\(titleValue)\n\n\(contentValue)"
            } else {
                self.analysis = "Deep analysis content will be loaded from the database..."
            }
            
            // Try to get key terms from the new structure
            if let keyTermsValue = content["key_terms"]?.value as? [String: Any] {
                var terms: [String: String] = [:]
                for (key, value) in keyTermsValue {
                    if let stringValue = value as? String {
                        terms[key] = stringValue
                    }
                }
                self.keyTerms = terms
            } else {
                // Fallback: create some default key terms based on the lesson
                self.keyTerms = [
                    "Dharma": "Righteous duty or moral law",
                    "Karma": "Action and its consequences",
                    "Yoga": "Path or discipline for spiritual growth"
                ]
            }
        } else {
            self.analysis = "Deep analysis content will be loaded from the database..."
            self.keyTerms = [
                "Dharma": "Righteous duty or moral law",
                "Karma": "Action and its consequences", 
                "Yoga": "Path or discipline for spiritual growth"
            ]
        }
    }
}

struct FinalThoughtsView: View {
    let lesson: DBLesson
    let lessonTitle: String
    let score: Int
    let totalQuestions: Int
    let timeElapsed: TimeInterval
    let lessonStartTime: Date
    let questionsAnswered: [String: Any]?
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var showPrayer = false
    @State private var audioManager = AudioManager.shared
    @State private var showingExitConfirmation = false
    @State private var dataManager = DataManager.shared
    @State private var isLoading = true
    @State private var finalThoughtsContent: FinalThoughtsContent?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    loadingView
                } else if let errorMessage = errorMessage {
                    errorView(errorMessage)
                } else if finalThoughtsContent == nil {
                    noDataView
                } else {
                    contentView
                }
                
                // Close in prayer button (only show when not loading and not in error state)
                if !isLoading && errorMessage == nil {
                    VStack {
                        Button(action: {
                            showPrayer = true
                        }) {
                            HStack {
                                Image(systemName: "hands.clap.fill")
                                Text("Closing Shloka")
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
            }
        }
        .navigationTitle("Final Thoughts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Exit") {
                    showingExitConfirmation = true
                }
            }
        }
        .fullScreenCover(isPresented: $showPrayer) {
            PrayerView(
                lesson: lesson,
                lessonTitle: lessonTitle,
                score: score,
                totalQuestions: totalQuestions,
                timeElapsed: timeElapsed,
                lessonStartTime: lessonStartTime,
                questionsAnswered: questionsAnswered,
                onDismiss: { showPrayer = false },
                onComplete: onComplete  // Direct pass-through, no complex logic
            )
        }
        .alert("Exit", isPresented: $showingExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                onComplete()
            }
        } message: {
            Text("Your progress will be lost. Are you sure you want to exit?")
        }
        .onAppear {
            loadFinalThoughtsContent()
        }
    }
    
    // MARK: - View Components
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
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
            
            VStack(spacing: 16) {
                Text("Final Thoughts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(lessonTitle)
                    .font(.title2)
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text("Loading analysis...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 16) {
                Text("Unable to Load Content")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Retry") {
                loadFinalThoughtsContent()
            }
            .buttonStyle(OrangeButtonStyle())
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var noDataView: some View {
        VStack(spacing: 24) {
            Spacer()
            
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
            
            VStack(spacing: 16) {
                Text("Final Thoughts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(lessonTitle)
                    .font(.title2)
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                Text("No data found for this lesson")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Final thoughts content is not available for \(lessonTitle)")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Final Thoughts")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(lessonTitle)
                        .font(.title2)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
                
                // Analysis content
                if let content = finalThoughtsContent {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Deep Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(content.analysis)
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                    }
                    
                    // Key terms
                    if !content.keyTerms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Terms")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            ForEach(Array(content.keyTerms.keys.sorted()), id: \.self) { term in
                                if let definition = content.keyTerms[term] {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(term)
                                            .font(.headline)
                                            .foregroundColor(.orange)
                                        
                                        Text(definition)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .lineSpacing(2)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadFinalThoughtsContent() {
        Task {
            do {
                print("📖 Loading final thoughts for lesson: \(lesson.title) (ID: \(lesson.id))")
                
                // Fetch lesson sections
                let sections = await dataManager.loadLessonSections(for: lesson.id)
                print("   Found \(sections.count) sections")
                
                // Find the FINAL_THOUGHTS section
                let finalThoughtsSection = sections.first { $0.kind == .finalThoughts }
                
                await MainActor.run {
                    if let section = finalThoughtsSection {
                        print("   ✅ Found FINAL_THOUGHTS section")
                        self.finalThoughtsContent = FinalThoughtsContent(from: section.content)
                        self.errorMessage = nil
                    } else {
                        print("   ⚠️ No FINAL_THOUGHTS section found")
                        self.finalThoughtsContent = nil
                        self.errorMessage = nil
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load final thoughts: \(error.localizedDescription)"
                    self.isLoading = false
                    print("   ❌ Error loading final thoughts: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Orange Button Style

struct OrangeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    FinalThoughtsView(
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
