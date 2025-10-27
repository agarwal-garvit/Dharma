//
//  SurveyManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import SwiftUI
import Supabase

@Observable
@MainActor
class SurveyManager {
    static let shared = SurveyManager()
    
    private let databaseService = DatabaseService.shared
    private let authManager = DharmaAuthManager.shared
    
    // Survey state
    var questions: [DBSurveyQuestion] = []
    var currentQuestionIndex = 0
    var answers: [String: [String]] = [:] // question_id -> [option_id(s)]
    var surveyResponse: DBSurveyResponse?
    var isLoading = false
    var errorMessage: String?
    
    // Survey completion status
    var hasCompletedSurvey = false
    var isSurveyAvailable = false
    
    private init() {}
    
    // MARK: - Survey Status Management
    
    func checkSurveyStatus(userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if user has a survey response
            if let response = try await databaseService.fetchUserSurveyResponse(userId: userId) {
                self.surveyResponse = response
                self.hasCompletedSurvey = response.completed
                self.answers = response.answers
                
                if !response.completed {
                    // User has started but not completed survey
                    self.isSurveyAvailable = true
                    await loadSurveyQuestions()
                }
            } else {
                // No survey response exists - user needs to take survey
                self.isSurveyAvailable = true
                await loadSurveyQuestions()
            }
        } catch {
            self.errorMessage = "Failed to check survey status: \(error.localizedDescription)"
            print("❌ Survey status check failed: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Survey Questions Management
    
    func loadSurveyQuestions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.questions = try await databaseService.fetchActiveSurveyQuestions()
            print("✅ Loaded \(questions.count) survey questions")
        } catch {
            self.errorMessage = "Failed to load survey questions: \(error.localizedDescription)"
            print("❌ Failed to load survey questions: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Answer Management
    
    func saveAnswer(questionId: String, answer: [String]) {
        answers[questionId] = answer
        print("💾 Saved answer for question \(questionId): \(answer)")
    }
    
    func getAnswer(for questionId: String) -> [String] {
        return answers[questionId] ?? []
    }
    
    func isAnswerSelected(questionId: String, optionId: String) -> Bool {
        return answers[questionId]?.contains(optionId) ?? false
    }
    
    func toggleAnswer(questionId: String, optionId: String, questionType: SurveyQuestionType) {
        var currentAnswers = answers[questionId] ?? []
        
        switch questionType {
        case .multipleChoice:
            // Single selection - replace current answer
            currentAnswers = [optionId]
        case .multiSelect:
            // Multiple selection - toggle option
            if currentAnswers.contains(optionId) {
                currentAnswers.removeAll { $0 == optionId }
            } else {
                currentAnswers.append(optionId)
            }
        }
        
        answers[questionId] = currentAnswers
        print("🔄 Toggled answer for question \(questionId): \(currentAnswers)")
    }
    
    // MARK: - Navigation
    
    func canGoToNext() -> Bool {
        guard currentQuestionIndex < questions.count else { return false }
        let currentQuestion = questions[currentQuestionIndex]
        let hasAnswer = !(answers[currentQuestion.id.uuidString]?.isEmpty ?? true)
        return hasAnswer
    }
    
    func goToNext() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func goToPrevious() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questions.count - 1
    }
    
    func isFirstQuestion() -> Bool {
        return currentQuestionIndex == 0
    }
    
    // MARK: - Survey Submission
    
    func submitSurvey() async {
        guard let userId = authManager.user?.id else {
            self.errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Create survey response if it doesn't exist
            if surveyResponse == nil {
                self.surveyResponse = try await databaseService.createSurveyResponse(userId: userId)
            }
            
            guard let response = surveyResponse else {
                self.errorMessage = "Failed to create survey response"
                return
            }
            
            // Update answers in database
            try await databaseService.updateSurveyAnswers(responseId: response.id, answers: answers)
            
            // Mark survey as completed
            try await databaseService.completeSurveyResponse(responseId: response.id)
            
            // Update local state
            self.hasCompletedSurvey = true
            self.isSurveyAvailable = false
            
            print("✅ Survey completed successfully")
            
        } catch {
            self.errorMessage = "Failed to submit survey: \(error.localizedDescription)"
            print("❌ Survey submission failed: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Reset Survey State
    
    func resetSurveyState() {
        questions = []
        currentQuestionIndex = 0
        answers = [:]
        surveyResponse = nil
        hasCompletedSurvey = false
        isSurveyAvailable = false
        errorMessage = nil
        isLoading = false
    }
    
    // MARK: - Progress Calculation
    
    func getProgress() -> Double {
        guard !questions.isEmpty else { return 0.0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    func getProgressText() -> String {
        return "\(currentQuestionIndex + 1) of \(questions.count)"
    }
}
