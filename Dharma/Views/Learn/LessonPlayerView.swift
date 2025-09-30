//
//  LessonPlayerView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct LessonPlayerView: View {
    let lesson: Lesson
    let onComplete: () -> Void
    
    @State private var dataManager = DataManager.shared
    @State private var currentExerciseIndex = 0
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var userAnswer = ""
    @State private var lessonCompleted = false
    
    private var exercises: [Exercise] {
        dataManager.getExercises(for: lesson)
    }
    
    private var currentExercise: Exercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    private var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(currentExerciseIndex) / Double(exercises.count)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .padding(.horizontal)
                    .padding(.top)
                
                if lessonCompleted {
                    lessonCompleteView
                } else if let exercise = currentExercise {
                    ExerciseView(
                        exercise: exercise,
                        onAnswerSubmitted: handleAnswer
                    )
                } else {
                    Text("No exercises available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        onComplete()
                    }
                }
            }
        }
    }
    
    private var lessonCompleteView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success animation
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Lesson Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Great job! You've completed '\(lesson.title)'")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Continue") {
                onComplete()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func handleAnswer(_ answer: String, isCorrect: Bool) {
        self.isCorrect = isCorrect
        self.userAnswer = answer
        showingResult = true
        
        // Provide haptic feedback
        if isCorrect {
            HapticManager.shared.correctAnswer()
        } else {
            HapticManager.shared.incorrectAnswer()
        }
        
        // Move to next exercise after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            nextExercise()
        }
    }
    
    private func nextExercise() {
        currentExerciseIndex += 1
        
        if currentExerciseIndex >= exercises.count {
            // Lesson completed
            completeLesson()
        } else {
            showingResult = false
            userAnswer = ""
        }
    }
    
    private func completeLesson() {
        lessonCompleted = true
        dataManager.completeLesson(lesson.id)
        HapticManager.shared.lessonComplete()
    }
}

struct ExerciseView: View {
    let exercise: Exercise
    let onAnswerSubmitted: (String, Bool) -> Void
    
    @State private var dataManager = DataManager.shared
    @State private var userAnswer = ""
    @State private var selectedOption: String?
    @State private var showingHint = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Exercise prompt
                Text(exercise.prompt)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                
                // Exercise content based on type
                switch exercise.type {
                case .readReveal:
                    readRevealView
                case .match:
                    matchView
                case .fillBlank:
                    fillBlankView
                case .orderTokens:
                    orderTokensView
                case .multipleChoice:
                    multipleChoiceView
                case .listening:
                    listeningView
                }
                
                // Hint button
                if let hints = exercise.hints, !hints.isEmpty {
                    Button("Show Hint") {
                        showingHint.toggle()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                if showingHint, let hints = exercise.hints {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(hints, id: \.self) { hint in
                            Text("• \(hint)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                
                // Submit button
                Button("Submit") {
                    submitAnswer()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canSubmit)
            }
            .padding()
        }
    }
    
    private var readRevealView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let verseRefs = exercise.verseRefs,
               let verseId = verseRefs.first,
               let verse = dataManager.getVerse(by: verseId) {
                
                // Show verse text based on user preference
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
                
                // Translation (initially hidden)
                Text(verse.translationEn)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(2)
                    .opacity(0.3)
                    .onTapGesture {
                        withAnimation {
                            // Reveal translation
                        }
                    }
            }
        }
    }
    
    private var matchView: some View {
        VStack(spacing: 16) {
            if let options = exercise.options {
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
            }
        }
    }
    
    private var fillBlankView: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Enter your answer", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
        }
    }
    
    private var orderTokensView: some View {
        VStack(spacing: 16) {
            Text("Drag to reorder the verse tokens")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Simplified token ordering (in a real app, this would be more sophisticated)
            if let verseRefs = exercise.verseRefs,
               let verseId = verseRefs.first,
               let verse = dataManager.getVerse(by: verseId) {
                
                let tokens = verse.iastText.components(separatedBy: " ")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(tokens, id: \.self) { token in
                        Text(token)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.1))
                            )
                    }
                }
            }
        }
    }
    
    private var multipleChoiceView: some View {
        VStack(spacing: 12) {
            if let options = exercise.options {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                    }) {
                        HStack {
                            Text(option)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedOption == option ? .orange : .gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedOption == option ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                                .stroke(selectedOption == option ? Color.orange : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var listeningView: some View {
        VStack(spacing: 16) {
            Button(action: {
                // Play audio
                if let verseRefs = exercise.verseRefs,
                   let verseId = verseRefs.first,
                   let verse = dataManager.getVerse(by: verseId) {
                    AudioManager.shared.playVerse(verse)
                }
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                    Text("Play Audio")
                        .font(.headline)
                }
                .foregroundColor(.orange)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Listen to the verse and select the correct meaning")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var canSubmit: Bool {
        switch exercise.type {
        case .readReveal:
            return true // Always can submit (just reveals content)
        case .match:
            return true // Simplified for demo
        case .fillBlank:
            return !userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .orderTokens:
            return true // Simplified for demo
        case .multipleChoice:
            return selectedOption != nil
        case .listening:
            return selectedOption != nil
        }
    }
    
    private func submitAnswer() {
        let answer: String
        let isCorrect: Bool
        
        switch exercise.type {
        case .readReveal:
            answer = "revealed"
            isCorrect = true
        case .match:
            answer = "matched"
            isCorrect = true // Simplified for demo
        case .fillBlank:
            answer = userAnswer
            isCorrect = checkFillBlankAnswer(userAnswer)
        case .orderTokens:
            answer = "ordered"
            isCorrect = true // Simplified for demo
        case .multipleChoice:
            answer = selectedOption ?? ""
            isCorrect = checkMultipleChoiceAnswer(selectedOption)
        case .listening:
            answer = selectedOption ?? ""
            isCorrect = checkMultipleChoiceAnswer(selectedOption)
        }
        
        onAnswerSubmitted(answer, isCorrect)
    }
    
    private func checkFillBlankAnswer(_ answer: String) -> Bool {
        guard let correctAnswer = exercise.correctAnswer else { return false }
        let correctAnswers = correctAnswer.components(separatedBy: ",")
        return correctAnswers.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
    }
    
    private func checkMultipleChoiceAnswer(_ answer: String?) -> Bool {
        guard let answer = answer,
              let correctAnswer = exercise.correctAnswer else { return false }
        return answer == correctAnswer
    }
}

#Preview {
    LessonPlayerView(
        lesson: Lesson(
            id: "preview",
            unitId: "unit_ch2",
            title: "Sample Lesson",
            objective: "Learn about karma yoga",
            exerciseIds: []
        ),
        onComplete: {}
    )
}
