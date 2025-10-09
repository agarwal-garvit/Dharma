//
//  QuizModels.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation

// MARK: - JSON-based Quiz Models

enum JSONQuizQuestionType: String, Codable, CaseIterable {
    case mcqSingle = "MCQ_SINGLE"
    case mcqMulti = "MCQ_MULTI"
    case trueFalse = "TRUEFALSE"
    case trueFalseAlt = "TRUE_FALSE"  // Alternative format support
    
    var displayName: String {
        switch self {
        case .mcqSingle: return "Multiple Choice (Single)"
        case .mcqMulti: return "Multiple Choice (Multiple)"
        case .trueFalse, .trueFalseAlt: return "True/False"
        }
    }
}

struct QuizQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let type: JSONQuizQuestionType
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}

struct QuizContent: Codable {
    let title: String
    let questions: [QuizQuestion]
}

// MARK: - Quiz Session Models

struct QuizSession {
    let questions: [QuizQuestion]
    let selectedIndices: [Int]
    let startTime: Date
    var currentQuestionIndex: Int = 0
    var score: Int = 0
    var answers: [Int?] = []
    
    init(questions: [QuizQuestion], maxQuestions: Int = 7) {
        // Normalize questions to handle TRUE_FALSE format
        let normalizedQuestions = questions.map { question in
            if question.type == .trueFalseAlt {
                return QuizQuestion(
                    id: question.id,
                    question: question.question,
                    type: .trueFalse,
                    options: question.options,
                    correctAnswer: question.correctAnswer,
                    explanation: question.explanation
                )
            }
            return question
        }
        
        self.questions = normalizedQuestions
        self.startTime = Date()
        
        // Select random questions in random order
        if normalizedQuestions.count <= maxQuestions {
            self.selectedIndices = Array(0..<normalizedQuestions.count).shuffled()
        } else {
            // Select random questions without replacement
            var allIndices = Array(0..<normalizedQuestions.count)
            var selectedIndices: [Int] = []
            
            for _ in 0..<maxQuestions {
                if let randomIndex = allIndices.randomElement() {
                    selectedIndices.append(randomIndex)
                    allIndices.removeAll { $0 == randomIndex }
                }
            }
            
            self.selectedIndices = selectedIndices
        }
        
        // Initialize answers array
        self.answers = Array(repeating: nil, count: self.selectedIndices.count)
        
        print("🎲 Quiz session created with \(selectedIndices.count) questions in random order: \(selectedIndices)")
    }
    
    var currentQuestion: QuizQuestion {
        questions[selectedIndices[currentQuestionIndex]]
    }
    
    var totalQuestions: Int {
        selectedIndices.count
    }
    
    var isComplete: Bool {
        currentQuestionIndex >= totalQuestions
    }
    
    var scorePercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }
    
    mutating func selectAnswer(_ answerIndex: Int) {
        if currentQuestionIndex < answers.count && answers[currentQuestionIndex] == nil {
            // Only calculate score if this is the first time answering this question
            answers[currentQuestionIndex] = answerIndex
            let isCorrect = answerIndex == currentQuestion.correctAnswer
            if isCorrect {
                score += 1
            }
            print("📊 Question \(currentQuestionIndex + 1): Selected \(answerIndex), Correct: \(currentQuestion.correctAnswer), IsCorrect: \(isCorrect), Score: \(score)/\(totalQuestions)")
        }
    }
    
    
    mutating func nextQuestion() {
        if currentQuestionIndex < totalQuestions - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func getQuestionResult(at index: Int) -> (isCorrect: Bool, selectedAnswer: Int?, correctAnswer: Int) {
        let questionIndex = selectedIndices[index]
        let question = questions[questionIndex]
        let selectedAnswer = answers[index]
        let isCorrect = selectedAnswer == question.correctAnswer
        
        return (isCorrect: isCorrect, selectedAnswer: selectedAnswer, correctAnswer: question.correctAnswer)
    }
}
