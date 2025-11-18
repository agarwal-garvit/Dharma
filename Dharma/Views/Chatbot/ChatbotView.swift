//
//  ChatbotView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ChatbotView: View {
    @StateObject private var chatManager = ChatManager()
    @State private var currentMessage = ""
    @State private var authManager = DharmaAuthManager.shared
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        if !authManager.isAuthenticated {
            // Sign in required view
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 64))
                        .foregroundColor(.orange.opacity(0.6))
                    
                    Text("Sign In Required")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Please sign in to start chatting with the Gita Guide.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // Chat interface
            NavigationView {
                ZStack {
                    // Background color
                    ThemeManager.appBackground
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                    // Messages
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Welcome message when empty
                            if chatManager.messages.isEmpty {
                                welcomeMessage
                            }
                            
                            // Chat messages
                            ForEach(chatManager.messages) { message in
                                ChatBubble(message: message)
                            }
                            
                            // Loading indicator
                            if chatManager.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            // Error message
                            if let errorMessage = chatManager.errorMessage {
                                Text("Error: \(errorMessage)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                    
                    // Input area
                    inputArea
                    }
                }
                .navigationTitle("Gita Guide")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if isTextFieldFocused {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                isTextFieldFocused = false
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            chatManager.clearConversation()
                        }
                        .disabled(chatManager.messages.isEmpty)
                    }
                }
                .onTapGesture {
                    // Dismiss keyboard when tapping outside TextField
                    isTextFieldFocused = false
                }
            }
        }
    }
    
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 30))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("Namaste! 🙏")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("I'm your guide to the Bhagavad Gita. Ask me anything about the sacred text or its teachings.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func sendExampleQuestion(_ question: String) {
        currentMessage = question
        sendMessage()
    }
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            // Example questions - horizontal scroll above input
            if chatManager.messages.isEmpty {
                exampleQuestionsScroll
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("Ask about the Bhagavad Gita...", text: $currentMessage, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .lineLimit(1...4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(currentMessage.isEmpty ? .gray : .orange)
                }
                .disabled(currentMessage.isEmpty || chatManager.isLoading)
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    private var exampleQuestionsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(exampleQuestions, id: \.self) { question in
                    Button(action: {
                        sendExampleQuestion(question)
                    }) {
                        Text(question)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
    
    private let exampleQuestions = [
        "What is dharma?",
        "Explain karma yoga",
        "What is the Bhagavad Gita about?",
        "Who is Krishna?",
        "What is moksha?",
        "Explain the three gunas",
        "What is bhakti yoga?",
        "What is the meaning of life?",
        "How to find inner peace?",
        "What is the soul?"
    ]
    
    private func sendMessage() {
        guard !currentMessage.isEmpty else { return }
        
        chatManager.sendMessage(currentMessage)
        currentMessage = ""
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.orange)
                        )
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
            } else {
                HStack(alignment: .top, spacing: 8) {
                    // Bot avatar
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(.systemGray6))
                            )
                        
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                }
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


#Preview {
    ChatbotView()
}