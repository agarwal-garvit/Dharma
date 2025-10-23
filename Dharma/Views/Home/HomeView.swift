//
//  HomeView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct HomeView: View {
    @State private var dataManager = DataManager.shared
    @State private var audioManager = AudioManager.shared
    @State private var showingQuickQuiz = false
    @State private var quickQuizAnswer = ""
    @State private var quickQuizResult: QuizResult?
    @State private var livesManager = LivesManager.shared
    
    private var verseOfTheDay: Verse? {
        dataManager.getVerseOfTheDay()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with streak and XP
                    headerView
                    
                    // Verse of the Day
                    if let verse = verseOfTheDay {
                        verseOfTheDayCard(verse)
                    }
                    
                    // Continue Learning Section
                    continueLearningSection
                    
                    // Progress Overview
                    progressOverview
                }
                .padding()
            }
            .navigationTitle("Dharma")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    LivesDisplayView()
                }
            }
        }
        .sheet(isPresented: $showingQuickQuiz) {
            if let verse = verseOfTheDay {
                QuickQuizView(verse: verse, result: $quickQuizResult)
            }
        }
        .onAppear {
            // Check and regenerate lives
            Task {
                await livesManager.checkAndRegenerateLives()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(dataManager.userProgress.streak)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(dataManager.userProgress.totalXP)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func verseOfTheDayCard(_ verse: Verse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Verse of the Day")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text("Chapter \(verse.chapterIndex), Verse \(verse.verseIndex)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    audioManager.playVerse(verse)
                }) {
                    Image(systemName: audioManager.isPlaying && audioManager.currentVerse?.id == verse.id ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            
            // Verse text based on user preference
            VStack(alignment: .leading, spacing: 12) {
                if dataManager.userPreferences.scriptDisplay == .devanagari || dataManager.userPreferences.scriptDisplay == .both {
                    Text(verse.devanagariText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .lineSpacing(4)
                }
                
                if dataManager.userPreferences.scriptDisplay == .iast || dataManager.userPreferences.scriptDisplay == .both {
                    Text(verse.iastText)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
                
                Text(verse.translationEn)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(2)
            }
            
            if let commentary = verse.commentaryShort {
                Text(commentary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 8)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button("Quick Quiz") {
                    showingQuickQuiz = true
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
                
                Button("Add to Review") {
                    // Add to review items
                    let reviewItem = ReviewItem(
                        id: "verse_\(verse.id)_\(Date().timeIntervalSince1970)",
                        kind: .verse,
                        payloadRef: verse.id
                    )
                    dataManager.reviewItems.append(reviewItem)
                    dataManager.saveUserData()
                    
                    HapticManager.shared.buttonTap()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var continueLearningSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Continue Learning")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Find next incomplete lesson
            let nextLesson = findNextIncompleteLesson()
            
            if let lesson = nextLesson {
                Button(action: {
                    // Navigate to lesson
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(lesson.objective)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Text("All lessons completed! 🎉")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
            }
        }
    }
    
    private var progressOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Overview")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                ProgressCard(
                    title: "Lessons",
                    completed: dataManager.userProgress.completedLessons.count,
                    total: dataManager.lessons.count,
                    icon: "book.fill",
                    color: .blue
                )
                
                ProgressCard(
                    title: "Units",
                    completed: dataManager.userProgress.completedUnits.count,
                    total: dataManager.chapters.count,
                    icon: "folder.fill",
                    color: .green
                )
            }
        }
    }
    
    private func findNextIncompleteLesson() -> Lesson? {
        guard let dbLesson = dataManager.lessons.first(where: { lesson in
            !dataManager.userProgress.completedLessons.contains(lesson.id.uuidString)
        }) else {
            return nil
        }
        
        // Convert DBLesson to legacy Lesson format
        return Lesson(
            id: dbLesson.id.uuidString,
            unitId: dbLesson.courseId.uuidString,
            title: dbLesson.title,
            objective: "Learn about \(dbLesson.title)",
            exerciseIds: []
        )
    }
}

struct ProgressCard: View {
    let title: String
    let completed: Int
    let total: Int
    let icon: String
    let color: Color
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Text("\(completed)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("/ \(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

enum QuizResult {
    case correct
    case incorrect
}

struct QuickQuizView: View {
    let verse: Verse
    @Binding var result: QuizResult?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAnswer = ""
    @State private var showingResult = false
    
    private let question = "What is the main theme of this verse?"
    private let options = [
        "Detachment from results",
        "Physical exercise",
        "Meditation techniques",
        "Ritual worship"
    ]
    private let correctAnswer = "Detachment from results"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(question)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedAnswer = option
                            showingResult = true
                            result = option == correctAnswer ? .correct : .incorrect
                            
                            if option == correctAnswer {
                                HapticManager.shared.correctAnswer()
                            } else {
                                HapticManager.shared.incorrectAnswer()
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.primary)
                                Spacer()
                                if showingResult {
                                    Image(systemName: option == correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(option == correctAnswer ? .green : .red)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(showingResult ? 
                                          (option == correctAnswer ? Color.green.opacity(0.1) : 
                                           option == selectedAnswer ? Color.red.opacity(0.1) : Color.gray.opacity(0.1)) :
                                          Color.gray.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(showingResult)
                    }
                }
                
                Spacer()
                
                if showingResult {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding()
            .navigationTitle("Quick Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
