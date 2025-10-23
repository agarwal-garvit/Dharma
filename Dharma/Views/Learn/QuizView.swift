//
//  QuizView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct QuizView: View {
    let sectionId: UUID
    let lesson: DBLesson
    let lessonTitle: String
    let lessonStartTime: Date
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var dataManager = DataManager.shared
    @State private var quizSession: QuizSession?
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showFinalThoughts = false
    @State private var showingExitConfirmation = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var questionsAnswered: [String: Any] = [:]
    @State private var showLivesModal = false
    @State private var livesManager = LivesManager.shared
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading quiz...")
                            .foregroundColor(.secondary)
                    }
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error loading quiz")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            loadQuiz()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let session = quizSession {
                    VStack(spacing: 0) {
                        // Progress bar
                        progressBar(session: session)
                        
                        // Question content
                        questionContent(session: session)
                    }
                } else {
                    VStack {
                        Text("No quiz available")
                            .font(.headline)
                        Text("This lesson doesn't have a quiz yet.")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        showingExitConfirmation = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    LivesDisplayView()
                }
            }
            .fullScreenCover(isPresented: $showFinalThoughts) {
                if let session = quizSession {
                    FinalThoughtsView(
                        lesson: lesson,
                        lessonTitle: lessonTitle,
                        score: session.score,
                        totalQuestions: session.totalQuestions,
                        timeElapsed: Date().timeIntervalSince(lessonStartTime),
                        lessonStartTime: lessonStartTime,
                        questionsAnswered: questionsAnswered,
                        onDismiss: onDismiss,
                        onComplete: onComplete
                    )
                }
            }
            .alert("Exit", isPresented: $showingExitConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Exit", role: .destructive) {
                    onComplete()
                }
            } message: {
                Text("Your progress will be lost. Are you sure you want to exit?")
            }
            .sheet(isPresented: $showLivesModal) {
                LivesModalView()
                    .onDisappear {
                        // When lives modal is dismissed and lives are 0, exit the quiz
                        if livesManager.currentLives == 0 {
                            onComplete()
                        }
                    }
            }
        }
        .onAppear {
            loadQuiz()
            
            // Check lives on quiz start
            Task {
                await livesManager.checkAndRegenerateLives()
            }
        }
    }
    
    private func progressBar(session: QuizSession) -> some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                
                Text("\(session.score)/\(session.totalQuestions)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            ProgressView(value: Double(session.currentQuestionIndex), total: Double(session.totalQuestions))
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .scaleEffect(y: 2.0) // Make progress bar thicker
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func questionContent(session: QuizSession) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Add some top spacing
                Spacer()
                    .frame(height: 20)
                
                // Question
                VStack(spacing: 16) {
                    Text(session.currentQuestion.question)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(0..<session.currentQuestion.options.count, id: \.self) { index in
                    Button(action: {
                        selectAnswer(index, session: session)
                    }) {
                        HStack {
                            Text(session.currentQuestion.options[index])
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if showResult {
                                if index == session.currentQuestion.correctAnswer {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else if selectedAnswer == index {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            } else if selectedAnswer == index {
                                Image(systemName: "circle.inset.filled")
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(getAnswerBackgroundColor(for: index, session: session))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(getAnswerBorderColor(for: index, session: session), lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedAnswer != nil)
                }
            }
            .padding(.horizontal)
            
            // Result message
            if showResult {
                VStack(spacing: 8) {
                    Text(isCorrect ? "Correct! 🎉" : "Incorrect 😔")
                        .font(.headline)
                        .foregroundColor(isCorrect ? .green : .red)
                    
                    if !isCorrect {
                        Text("The correct answer is: \(session.currentQuestion.options[session.currentQuestion.correctAnswer])")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Show explanation
                    Text(session.currentQuestion.explanation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
                .padding(.horizontal)
            }
            
            // Next button
            if showResult {
                Button(action: {
                    nextQuestion(session: session)
                }) {
                    Text(session.currentQuestionIndex < session.totalQuestions - 1 ? "Next Question" : "Complete Quiz")
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
                .padding(.horizontal)
            }
            }
            .padding(.bottom)
        }
    }
    
    private func loadQuiz() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                if let quizContent = await dataManager.loadQuizContent(for: sectionId) {
                    await MainActor.run {
                        self.quizSession = QuizSession(questions: quizContent.questions, maxQuestions: 5)
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Failed to load quiz content"
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func selectAnswer(_ index: Int, session: QuizSession) {
        selectedAnswer = index
        isCorrect = index == session.currentQuestion.correctAnswer
        
        // Update the session score - ensure we're using the current session
        if var currentSession = quizSession {
            let oldScore = currentSession.score
            currentSession.selectAnswer(index)
            quizSession = currentSession
            
            // Track the question and answer for comprehensive logging
            let question = currentSession.currentQuestion
            questionsAnswered[question.id] = [
                "question": question.question,
                "selectedAnswer": index,
                "correctAnswer": question.correctAnswer,
                "isCorrect": index == question.correctAnswer,
                "options": question.options
            ]
            
            print("🎯 QuizView: Answer \(index) selected, Score: \(oldScore) → \(currentSession.score)")
        }
        
        // Deduct a life if answer is incorrect
        if !isCorrect {
            Task {
                await livesManager.deductLife()
                
                // If lives hit 0, show the lives modal
                if livesManager.currentLives == 0 {
                    await MainActor.run {
                        print("💔 QuizView: Lives depleted - showing modal and will exit quiz")
                        showLivesModal = true
                    }
                }
            }
        }
        
        withAnimation {
            showResult = true
        }
    }
    
    private func nextQuestion(session: QuizSession) {
        if session.currentQuestionIndex < session.totalQuestions - 1 {
            quizSession?.currentQuestionIndex += 1
            selectedAnswer = nil
            showResult = false
        } else {
            let totalTime = Date().timeIntervalSince(lessonStartTime)
            print("🏁 Quiz completed! Final score: \(session.score)/\(session.totalQuestions) (\(String(format: "%.1f", session.scorePercentage))%)")
            print("⏱️ Total time elapsed: \(Int(totalTime)) seconds (\(Int(totalTime/60)):\(String(format: "%02d", Int(totalTime.truncatingRemainder(dividingBy: 60))))")
            showFinalThoughts = true
        }
    }
    
    private func getAnswerBackgroundColor(for index: Int, session: QuizSession) -> Color {
        if showResult {
            if index == session.currentQuestion.correctAnswer {
                return Color.green.opacity(0.1)
            } else if selectedAnswer == index {
                return Color.red.opacity(0.1)
            }
        } else if selectedAnswer == index {
            return Color.orange.opacity(0.1)
        }
        return Color(.systemGray6)
    }
    
    private func getAnswerBorderColor(for index: Int, session: QuizSession) -> Color {
        if showResult {
            if index == session.currentQuestion.correctAnswer {
                return Color.green
            } else if selectedAnswer == index {
                return Color.red
            }
        } else if selectedAnswer == index {
            return Color.orange
        }
        return Color.clear
    }
}

#Preview {
    QuizView(
        sectionId: UUID(),
        lesson: DBLesson(id: UUID(), courseId: UUID(), orderIdx: 2, title: "Sankhya Yoga", imageUrl: nil),
        lessonTitle: "Sankhya Yoga",
        lessonStartTime: Date(),
        onDismiss: {},
        onComplete: {}
    )
}
