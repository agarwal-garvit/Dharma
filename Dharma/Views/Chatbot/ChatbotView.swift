//
//  ChatbotView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ChatbotView: View {
    @State private var chatManager = ChatManager()
    @State private var currentMessage = ""
    @State private var showingSuggestions = true
    @State private var showingHistory = false
    @State private var authManager = DharmaAuthManager.shared
    
    var body: some View {
        if !authManager.isAuthenticated {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        } else {
            NavigationView {
                VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Welcome message
                            if chatManager.messages.isEmpty {
                                welcomeSection
                            }
                            
                            // Chat messages
                            ForEach(chatManager.messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
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
                        }
                        .padding()
                    }
                    .onChange(of: chatManager.messages.count) { _, _ in
                        if let lastMessage = chatManager.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Suggestions
                if showingSuggestions && chatManager.messages.isEmpty {
                    suggestionsSection
                }
                
                // Input area
                inputSection
            }
            .navigationTitle("Gita Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("History") {
                        showingHistory = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        clearChat()
                    }
                    .disabled(chatManager.messages.isEmpty)
                }
            }
            .sheet(isPresented: $showingHistory) {
                ConversationHistoryView()
            }
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            // Bot avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 30))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("Namaste! 🙏")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("I'm your guide to the Bhagavad Gita. Ask me anything about the sacred text, its teachings, or how to apply them in your daily life.")
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
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Try asking:")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(suggestedQuestions, id: \.self) { question in
                        Button(action: {
                            sendMessage(question)
                        }) {
                            Text(question)
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.orange.opacity(0.1))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 8)
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
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
                
                Button(action: {
                    sendMessage(currentMessage)
                }) {
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
    
    private let suggestedQuestions = [
        "What is karma yoga?",
        "Explain verse 2.47",
        "How to practice detachment?",
        "What is dharma?",
        "Tell me about Arjuna's dilemma"
    ]
    
    private func sendMessage(_ text: String) {
        chatManager.sendMessage(text)
        currentMessage = ""
        showingSuggestions = false
    }
    
    private func clearChat() {
        chatManager.clearConversation()
        showingSuggestions = true
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
