//
//  ConversationHistoryView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ConversationHistoryView: View {
    @State private var chatManager = ChatManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if chatManager.conversations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(.orange.opacity(0.6))
                        
                        Text("No conversations yet")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Start a conversation with the Gita Guide to see your chat history here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(chatManager.conversations) { conversation in
                        ConversationRow(conversation: conversation)
                            .onTapGesture {
                                chatManager.loadConversation(conversation.id)
                                dismiss()
                            }
                    }
                    .onDelete(perform: deleteConversations)
                }
            }
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
                        chatManager.startNewConversation()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            chatManager.loadConversations()
        }
    }
    
    private func deleteConversations(offsets: IndexSet) {
        for index in offsets {
            let conversation = chatManager.conversations[index]
            chatManager.deleteConversation(conversation.id)
        }
    }
}

struct ConversationRow: View {
    let conversation: ChatConversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(conversation.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack {
                Text(formatDate(conversation.updatedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(conversation.messageCount) messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ConversationHistoryView()
}
