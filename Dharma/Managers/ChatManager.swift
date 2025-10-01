//
//  ChatManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import Supabase

@MainActor
class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: Config.supabaseURLObject,
        supabaseKey: Config.supabaseKey
    )
    
    init() {
        loadConversationHistory()
    }
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(
            id: UUID(),
            content: text,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let aiResponse = try await getAIResponse(for: text, conversationHistory: messages)
                let aiMessage = ChatMessage(
                    id: UUID(),
                    content: aiResponse,
                    isUser: false,
                    timestamp: Date()
                )
                
                await MainActor.run {
                    messages.append(aiMessage)
                    isLoading = false
                    saveConversationHistory()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to get AI response: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    func clearConversation() {
        messages.removeAll()
        saveConversationHistory()
    }
    
    private func getAIResponse(for userMessage: String, conversationHistory: [ChatMessage]) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare messages for OpenAI
        var openAIMessages: [[String: String]] = []
        
        // System prompt
        openAIMessages.append([
            "role": "system",
            "content": """
            You are a wise and compassionate spiritual guide specializing in Hindu philosophy, particularly the Bhagavad Gita. Your role is to help users understand and apply the teachings of the Gita in their daily lives.
            
            Guidelines:
            - Provide thoughtful, practical advice based on Gita teachings
            - Use simple, accessible language while maintaining depth
            - Reference specific verses when relevant (e.g., "As Krishna says in Chapter 2, Verse 47...")
            - Help users understand concepts like dharma, karma, and self-realization
            - Encourage spiritual growth and self-reflection
            - Be supportive and non-judgmental
            - Keep responses concise but meaningful (2-3 paragraphs max)
            - If asked about topics outside Hindu philosophy, gently redirect to relevant Gita teachings
            
            Remember: You are here to guide, not preach. Help users find their own path to wisdom.
            """
        ])
        
        // Add conversation history (last 10 messages to stay within token limits)
        let recentHistory = Array(conversationHistory.suffix(10))
        for message in recentHistory {
            openAIMessages.append([
                "role": message.isUser ? "user" : "assistant",
                "content": message.content
            ])
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": openAIMessages,
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ChatError.networkError
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = jsonResponse?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw ChatError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func saveConversationHistory() {
        do {
            let data = try JSONEncoder().encode(messages)
            UserDefaults.standard.set(data, forKey: "conversation_history")
        } catch {
            print("Failed to save conversation history: \(error)")
        }
    }
    
    private func loadConversationHistory() {
        guard let data = UserDefaults.standard.data(forKey: "conversation_history") else { return }
        
        do {
            messages = try JSONDecoder().decode([ChatMessage].self, from: data)
        } catch {
            print("Failed to load conversation history: \(error)")
        }
    }
}

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
}

enum ChatError: Error, LocalizedError {
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error occurred"
        case .invalidResponse:
            return "Invalid response from AI service"
        }
    }
}
