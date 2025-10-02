//
//  ConversationHistoryView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ConversationHistoryView: View {
    @State private var chatManager = ChatManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 48))
                    .foregroundColor(.orange.opacity(0.6))
                
                Text("Chat History")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Your conversation history is automatically saved. Start a new conversation with the Gita Guide to begin your spiritual journey.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if !chatManager.messages.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Conversation")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(chatManager.messages.count) messages")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Chat History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Chat") {
                        chatManager.clearConversation()
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    ConversationHistoryView()
}
