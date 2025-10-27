//
//  SurveyQuestionView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct SurveyQuestionView: View {
    let question: DBSurveyQuestion
    let selectedAnswers: [String]
    let onAnswerSelected: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Question Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(question.questionText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(question.questionType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(question.options, id: \.id) { option in
                        SurveyOptionView(
                            option: option,
                            isSelected: selectedAnswers.contains(option.id),
                            questionType: question.questionType,
                            onTap: {
                                onAnswerSelected(option.id)
                            }
                        )
                    }
                }
                
                Spacer(minLength: 100) // Space for navigation buttons
            }
            .padding()
        }
    }
}

struct SurveyOptionView: View {
    let option: SurveyOption
    let isSelected: Bool
    let questionType: SurveyQuestionType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 16, height: 16)
                        
                        if questionType == .multiSelect {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Option text
                Text(option.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.1) : Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    let sampleQuestion = DBSurveyQuestion(
        id: UUID(),
        questionText: "What is your primary motivation for learning about the Bhagavad Gita?",
        questionType: .multipleChoice,
        options: [
            SurveyOption(id: "1", text: "Spiritual growth and enlightenment"),
            SurveyOption(id: "2", text: "Understanding Hindu philosophy"),
            SurveyOption(id: "3", text: "Personal development and life guidance"),
            SurveyOption(id: "4", text: "Academic or scholarly interest")
        ],
        orderIdx: 1,
        isActive: true,
        createdAt: nil,
        updatedAt: nil
    )
    
    SurveyQuestionView(
        question: sampleQuestion,
        selectedAnswers: ["1"],
        onAnswerSelected: { _ in }
    )
}
