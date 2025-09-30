//
//  ChatbotView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ChatbotView: View {
    @State private var messages: [ChatMessage] = []
    @State private var currentMessage = ""
    @State private var isLoading = false
    @State private var showingSuggestions = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Welcome message
                            if messages.isEmpty {
                                welcomeSection
                            }
                            
                            // Chat messages
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            
                            // Loading indicator
                            if isLoading {
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
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Suggestions
                if showingSuggestions && messages.isEmpty {
                    suggestionsSection
                }
                
                // Input area
                inputSection
            }
            .navigationTitle("Gita Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        clearChat()
                    }
                    .disabled(messages.isEmpty)
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
                .disabled(currentMessage.isEmpty || isLoading)
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
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            content: text,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        currentMessage = ""
        showingSuggestions = false
        isLoading = true
        
        // Simulate bot response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let botResponse = generateBotResponse(for: text)
            let botMessage = ChatMessage(
                id: UUID(),
                content: botResponse,
                isUser: false,
                timestamp: Date()
            )
            
            messages.append(botMessage)
            isLoading = false
        }
    }
    
    private func generateBotResponse(for question: String) -> String {
        let lowercaseQuestion = question.lowercased()
        
        if lowercaseQuestion.contains("karma yoga") {
            return "Karma Yoga is the path of selfless action. As Krishna teaches in the Bhagavad Gita, it means performing your duties without attachment to the results. The key principle is: 'You have a right to action alone, not to its fruits' (2.47). This helps us maintain equanimity in success and failure."
        } else if lowercaseQuestion.contains("2.47") || lowercaseQuestion.contains("verse 2.47") {
            return "Verse 2.47 is one of the most famous verses: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन' (karmaṇy-evādhikāras te mā phaleṣu kadācana). It means 'You have a right to action alone, not to its fruits.' This teaches us to focus on our efforts rather than outcomes, leading to inner peace and spiritual growth."
        } else if lowercaseQuestion.contains("detachment") {
            return "Detachment (vairagya) in the Gita means performing actions without being emotionally attached to results. It's not about avoiding action, but about maintaining inner balance. Krishna teaches that true detachment comes from understanding our eternal nature and seeing all actions as offerings to the Divine."
        } else if lowercaseQuestion.contains("dharma") {
            return "Dharma is your righteous duty or purpose in life. The Gita teaches that everyone has a unique dharma based on their nature and circumstances. Following dharma means doing what is right according to your role in society, while maintaining spiritual awareness and detachment from results."
        } else if lowercaseQuestion.contains("arjuna") {
            return "Arjuna's dilemma represents the universal human struggle between duty and emotion. Faced with fighting his own family in the Kurukshetra war, Arjuna questions the righteousness of violence. Krishna's teachings help him understand that sometimes our dharma requires difficult actions for the greater good."
        } else {
            return "That's a great question about the Bhagavad Gita! The sacred text offers profound wisdom on life, duty, and spirituality. While I'm still learning, I can help you explore concepts like karma yoga, dharma, detachment, and the nature of the self. Feel free to ask about specific verses or teachings!"
        }
    }
    
    private func clearChat() {
        messages.removeAll()
        showingSuggestions = true
        currentMessage = ""
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
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
