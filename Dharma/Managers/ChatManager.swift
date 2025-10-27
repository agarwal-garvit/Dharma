//
//  ChatManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import Supabase
import Combine

class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase: SupabaseClient
    
    private var currentConversationId: UUID?
    private let authManager = DharmaAuthManager.shared
    
    init() {
        // Use the same Supabase client as AuthManager to ensure authentication context is shared
        self.supabase = SupabaseClient(
            supabaseURL: Config.supabaseURLObject,
            supabaseKey: Config.supabaseKey
        )
        // Start with empty chat - will create conversation when first message is sent
    }
    
    func sendMessage(_ text: String) {
        // Add user message immediately
        let userMessage = ChatMessage(
            conversationId: currentConversationId,
            content: text,
            isUser: true
        )
        messages.append(userMessage)
        
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        // Get AI response and save to database
        Task {
            do {
                // Create conversation if this is the first message
                if currentConversationId == nil {
                    currentConversationId = try await createConversation(title: text)
                }
                
                // Save user message to database
                try await saveMessageToDatabase(userMessage)
                
                // Get AI response
                let aiResponse = try await getAIResponse(for: text)
                
                // Create AI message
                let aiMessage = ChatMessage(
                    conversationId: currentConversationId,
                    content: aiResponse,
                    isUser: false
                )
                
                // Save AI message to database
                try await saveMessageToDatabase(aiMessage)
                
                // Add AI response on main thread
                await MainActor.run {
                    self.messages.append(aiMessage)
                    self.isLoading = false
                }
            } catch {
                // Handle error on main thread
                await MainActor.run {
                    self.errorMessage = "Failed to get AI response: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearConversation() {
        messages.removeAll()
        currentConversationId = nil
        errorMessage = nil
    }
    
    // MARK: - Future: Load Conversation History
    
    func loadConversation(conversationId: UUID) async throws {
        // This can be implemented later to load previous conversations
        // For now, we start fresh each time
    }
    
    // MARK: - Database Functions
    
    private func createConversation(title: String) async throws -> UUID {
        guard let userId = authManager.user?.id else {
            print("❌ [CHAT] No authenticated user found")
            throw ChatError.authenticationError
        }
        
        print("🔍 [CHAT] Creating conversation for user: \(userId)")
        print("🔍 [CHAT] Title: \(title)")
        
        let conversation = ChatConversation(
            id: UUID(),
            userId: userId,
            title: String(title.prefix(50)), // Limit title length
            createdAt: Date(),
            updatedAt: Date(),
            messageCount: 0
        )
        
        do {
            let response: ChatConversation = try await supabase.database
                .from("chat_conversations")
                .insert(conversation)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ [CHAT] Conversation created successfully: \(response.id)")
            return response.id
        } catch {
            print("❌ [CHAT] Failed to create conversation: \(error)")
            print("❌ [CHAT] Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ [CHAT] Error domain: \(nsError.domain), code: \(nsError.code)")
                print("❌ [CHAT] User info: \(nsError.userInfo)")
            }
            throw error
        }
    }
    
    private func saveMessageToDatabase(_ message: ChatMessage) async throws {
        print("🔍 [CHAT] Saving message to database")
        print("🔍 [CHAT] Message ID: \(message.id)")
        print("🔍 [CHAT] Conversation ID: \(message.conversationId?.uuidString ?? "nil")")
        print("🔍 [CHAT] Content: \(message.content)")
        print("🔍 [CHAT] Is User: \(message.isUser)")
        
        // Create a proper message object for database insertion
        let messageForDB = ChatMessageForDB(
            id: message.id,
            conversationId: message.conversationId,
            content: message.content,
            isUser: message.isUser,
            timestamp: message.timestamp
        )
        
        do {
            try await supabase.database
                .from("chat_messages")
                .insert(messageForDB)
                .execute()
            
            print("✅ [CHAT] Message saved successfully")
        } catch {
            print("❌ [CHAT] Failed to save message: \(error)")
            print("❌ [CHAT] Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ [CHAT] Error domain: \(nsError.domain), code: \(nsError.code)")
                print("❌ [CHAT] User info: \(nsError.userInfo)")
            }
            throw error
        }
    }
    
    private func getAIResponse(for userMessage: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Simple request body
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a wise spiritual guide specializing in the Bhagavad Gita. Provide helpful, concise responses about Hindu philosophy and the Gita's teachings."
                ],
                [
                    "role": "user",
                    "content": userMessage
                ]
            ],
            "max_tokens": 300,
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
}

enum ChatError: Error, LocalizedError {
    case networkError
    case invalidResponse
    case authenticationError
    case databaseError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error occurred"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .authenticationError:
            return "User not authenticated"
        case .databaseError:
            return "Database error occurred"
        }
    }
}