//
//  FeedbackSubmissionView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI
import Supabase

struct FeedbackSubmissionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType: FeedbackType = .feedback
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    
    private let maxCharacterCount = 1000
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Contact Support")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("We'd love to hear from you! Share your feedback, report issues, or ask questions.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Feedback Type Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What can we help you with?")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                ForEach(FeedbackType.allCases, id: \.self) { type in
                                    FeedbackTypeView(
                                        type: type,
                                        isSelected: feedbackType == type,
                                        onTap: {
                                            feedbackType = type
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .padding(.horizontal)
                        
                        // Message Input
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Message")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                TextEditor(text: $message)
                                    .frame(minHeight: 120)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                HStack {
                                    Spacer()
                                    Text("\(message.count)/\(maxCharacterCount)")
                                        .font(.caption)
                                        .foregroundColor(message.count > maxCharacterCount ? .red : .secondary)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .padding(.horizontal)
                        
                        // Submit Button
                        Button(action: submitFeedback) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isSubmitting ? "Submitting..." : "Submit Feedback")
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                                 message.count > maxCharacterCount || 
                                 isSubmitting)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .alert("Success", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you for your feedback! We'll review it and get back to you if needed.")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func submitFeedback() {
        guard let userId = DharmaAuthManager.shared.user?.id else {
            errorMessage = "You must be logged in to submit feedback."
            return
        }
        
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            errorMessage = "Please enter a message."
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                let databaseService = DatabaseService.shared
                _ = try await databaseService.submitUserFeedback(
                    userId: userId,
                    type: feedbackType.rawValue,
                    message: trimmedMessage,
                    context: "Help FAQ"
                )
                
                await MainActor.run {
                    isSubmitting = false
                    showingSuccess = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "Failed to submit feedback: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct FeedbackTypeView: View {
    let type: FeedbackType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(typeDescription(for: type))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .orange : .gray)
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
    }
    
    private func typeDescription(for type: FeedbackType) -> String {
        switch type {
        case .issue:
            return "Report bugs or technical problems"
        case .feedback:
            return "Share suggestions or general feedback"
        case .question:
            return "Ask questions about the app"
        }
    }
}

#Preview {
    FeedbackSubmissionView()
}
