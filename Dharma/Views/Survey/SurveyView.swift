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
    @State private var isSubmitting = false
    
    var body: some View {
        ZStack {
            // Background
            ThemeManager.appBackground
                .ignoresSafeArea()
            
            if isSubmitting {
                submittingView
            } else if surveyManager.questions.isEmpty {
                // Show welcome page while loading
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
                        
                        Text("Preparing your personalized experience...")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                    
                    Spacer()
                }
                .padding()
            } else if !hasStartedSurvey {
                // Personalization Questionnaire Page
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 30) {
                        Image("app-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        VStack(spacing: 16) {
                            Text("Personalization Questionnaire")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Let's get to know you better")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(spacing: 12) {
                            Text("We'll ask you a few questions about your spiritual interests and learning preferences")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Text("This helps us customize your Dharma experience and recommend the most relevant content")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button("Begin Questionnaire") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                hasStartedSurvey = true
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Text("\(surveyManager.questions.count) questions • Takes about 2-3 minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 24)
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
                                // Prevent multiple submissions
                                guard !surveyManager.isLoading && !isSubmitting else { return }
                                
                                // Show submitting view immediately
                                isSubmitting = true
                                
                                Task {
                                    await surveyManager.submitSurvey()
                                    
                                    // Small delay to show submitting view
                                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                                    
                                    await MainActor.run {
                                        // Show introduction after submission
                                        showingIntroduction = true
                                    }
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
                            .disabled(!surveyManager.canGoToNext() || surveyManager.isLoading || isSubmitting)
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
            // Reset survey start state when loading survey
            hasStartedSurvey = false
            
            // Load survey questions if not already loaded
            if surveyManager.questions.isEmpty {
                Task {
                    await surveyManager.loadSurveyQuestions()
                }
            }
        }
        .overlay(
            Group {
                if showingIntroduction {
                    AppIntroductionView()
                        .onDisappear {
                            // Survey is complete, reset state and notify main app
                            surveyManager.resetSurveyState()
                            isSubmitting = false
                            // Notify that we're ready to show main app
                            NotificationCenter.default.post(name: .surveyCompleted, object: nil)
                        }
                }
            }
        )
    }
    
    // MARK: - Submitting View
    
    private var submittingView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App icon
            Image("app-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 16) {
                Text("Submitting Survey")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Please wait while we process your responses...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                
                Text("Saving your preferences")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeManager.appBackground)
    }
}

#Preview {
    SurveyView()
}
