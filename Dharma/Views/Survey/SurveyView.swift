//
//  SurveyView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import Supabase

struct SurveyView: View {
    @State private var surveyManager = SurveyManager.shared
    @State private var showingIntroduction = false
    
    var body: some View {
        ZStack {
            // Background
            ThemeManager.appBackground
                .ignoresSafeArea()
            
            if surveyManager.isLoading {
                ProgressView("Loading survey...")
                    .font(.headline)
                    .foregroundColor(.primary)
            } else if surveyManager.questions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Survey Unavailable")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("We're having trouble loading the survey. Please try again later.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Retry") {
                        Task {
                            await surveyManager.loadSurveyQuestions()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    // Progress Header
                    VStack(spacing: 16) {
                        HStack {
                            Text("Welcome to Dharma")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(surveyManager.getProgressText())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: surveyManager.getProgress())
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    
                    // Question Content
                    if surveyManager.currentQuestionIndex < surveyManager.questions.count {
                        let currentQuestion = surveyManager.questions[surveyManager.currentQuestionIndex]
                        
                        SurveyQuestionView(
                            question: currentQuestion,
                            selectedAnswers: surveyManager.getAnswer(for: currentQuestion.id.uuidString),
                            onAnswerSelected: { optionId in
                                surveyManager.toggleAnswer(
                                    questionId: currentQuestion.id.uuidString,
                                    optionId: optionId,
                                    questionType: currentQuestion.questionType
                                )
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    
                    Spacer()
                    
                    // Navigation Footer
                    HStack {
                        if !surveyManager.isFirstQuestion() {
                            Button("Back") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    surveyManager.goToPrevious()
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        
                        Spacer()
                        
                        if surveyManager.isLastQuestion() {
                            Button("Complete Survey") {
                                Task {
                                    await surveyManager.submitSurvey()
                                    if surveyManager.hasCompletedSurvey {
                                        showingIntroduction = true
                                    }
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(!surveyManager.canGoToNext() || surveyManager.isLoading)
                        } else {
                            Button("Next") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    surveyManager.goToNext()
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(!surveyManager.canGoToNext())
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
        }
        .onAppear {
            Task {
                if let userId = DharmaAuthManager.shared.user?.id {
                    await surveyManager.checkSurveyStatus(userId: userId)
                }
            }
        }
        .fullScreenCover(isPresented: $showingIntroduction) {
            AppIntroductionView()
        }
        .alert("Survey Error", isPresented: .constant(surveyManager.errorMessage != nil)) {
            Button("OK") {
                surveyManager.errorMessage = nil
            }
        } message: {
            Text(surveyManager.errorMessage ?? "")
        }
    }
}

#Preview {
    SurveyView()
}
