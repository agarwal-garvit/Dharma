//
//  QuizView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct QuizView: View {
    let chapterIndex: Int
    let chapterTitle: String
    let lessonStartTime: Date
    let onDismiss: () -> Void
    let onComplete: () -> Void
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var startTime = Date()
    @State private var showFinalThoughts = false
    
    private let questions = [
        QuizQuestion(
            question: "What is the main teaching of Karma Yoga?",
            options: [
                "Perform actions without attachment to results",
                "Avoid all actions completely",
                "Only perform religious actions",
                "Focus only on personal gain"
            ],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "According to Krishna, what is the nature of the soul?",
            options: [
                "Temporary and destructible",
                "Eternal and indestructible",
                "Created at birth",
                "Destroyed at death"
            ],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "What does 'dharma' mean in the context of the Gita?",
            options: [
                "Religious rituals",
                "One's righteous duty",
                "Meditation practice",
                "Sacred texts"
            ],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "How should one perform their duties according to Krishna?",
            options: [
                "With attachment to results",
                "Without attachment to results",
                "Only for personal benefit",
                "Avoiding all responsibilities"
            ],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "What is the key to inner peace according to the Gita?",
            options: [
                "Avoiding all challenges",
                "Performing duties with detachment",
                "Seeking only pleasure",
                "Isolating from society"
            ],
            correctAnswer: 1
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
                // Progress bar
                progressBar
                
                // Question content
                questionContent
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        onDismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showFinalThoughts) {
                FinalThoughtsView(
                    chapterIndex: chapterIndex,
                    chapterTitle: chapterTitle,
                    score: score,
                    totalQuestions: questions.count,
                    timeElapsed: Date().timeIntervalSince(lessonStartTime),
                    onDismiss: onDismiss,
                    onComplete: onComplete
                )
            }
        }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(score)/\(questions.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var questionContent: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Question
            VStack(spacing: 16) {
                Text(questions[currentQuestionIndex].question)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                    Button(action: {
                        selectAnswer(index)
                    }) {
                        HStack {
                            Text(questions[currentQuestionIndex].options[index])
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if selectedAnswer == index {
                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(isCorrect ? .green : .red)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedAnswer == index ? 
                                    (isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1)) : 
                                    Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAnswer == index ? 
                                            (isCorrect ? Color.green : Color.red) : 
                                            Color.clear, lineWidth: 2)
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
                        Text("The correct answer is: \(questions[currentQuestionIndex].options[questions[currentQuestionIndex].correctAnswer])")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Next button
            if showResult {
                Button(action: {
                    nextQuestion()
                }) {
                    Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "View Final Thoughts")
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
    
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        isCorrect = index == questions[currentQuestionIndex].correctAnswer
        
        if isCorrect {
            score += 1
        }
        
        withAnimation {
            showResult = true
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showResult = false
        } else {
            showFinalThoughts = true
        }
    }
}

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
}

#Preview {
    QuizView(
        chapterIndex: 2,
        chapterTitle: "Sankhya Yoga",
        lessonStartTime: Date(),
        onDismiss: {},
        onComplete: {}
    )
}
