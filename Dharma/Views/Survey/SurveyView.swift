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
    @State private var hasStartedSurvey = false
    
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
            } else if !hasStartedSurvey {
                // Welcome Page
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image("app-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(spacing: 16) {
                        Text("Welcome to Dharma")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Let's get to know you better")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 12) {
                        Text("We'll ask you a few questions to personalize your learning experience")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Text("This will help us recommend the best content for your spiritual journey")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button("Begin Survey") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                hasStartedSurvey = true
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Text("\(surveyManager.questions.count) questions • Takes about 2-3 minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    // Progress Header
                    VStack(spacing: 16) {
                        HStack {
                            Text("Survey")
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
                            Button(action: {
                                Task {
                                    await surveyManager.submitSurvey()
                                    // Show introduction even if survey submission fails
                                    // This ensures user can continue with the app
                                    showingIntroduction = true
                                }
                            }) {
                                HStack {
                                    if surveyManager.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.white)
                                    }
                                    Text(surveyManager.isLoading ? "Submitting..." : "Complete Survey")
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
                    // Reset survey start state when loading survey
                    hasStartedSurvey = false
                }
            }
        }
        .fullScreenCover(isPresented: $showingIntroduction) {
            AppIntroductionView()
        }
        .alert("Survey Error", isPresented: .constant(surveyManager.errorMessage != nil)) {
            Button("Retry") {
                surveyManager.errorMessage = nil
                Task {
                    await surveyManager.submitSurvey()
                    showingIntroduction = true
                }
            }
            Button("Continue Anyway") {
                surveyManager.errorMessage = nil
                showingIntroduction = true
            }
        } message: {
            Text(surveyManager.errorMessage ?? "")
        }
    }
}

#Preview {
    SurveyView()
}
