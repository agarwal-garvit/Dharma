//
//  HelpFAQView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct HelpFAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingFeedback = false
    @State private var expandedFAQ: String? = nil
    
    private let faqItems = [
        FAQItem(
            id: "getting-started",
            question: "How do I get started with Dharma?",
            answer: "Welcome to Dharma! Start by exploring the Learn section where you'll find structured lessons about the Bhagavad Gita. Each lesson includes summaries, quizzes, and reflections to deepen your understanding."
        ),
        FAQItem(
            id: "daily-practice",
            question: "What is the Daily section for?",
            answer: "The Daily section helps you build a consistent spiritual practice. You'll receive daily verses, set study reminders, and track your progress to maintain your journey with the Bhagavad Gita."
        ),
        FAQItem(
            id: "progress-tracking",
            question: "How does progress tracking work?",
            answer: "Your progress is automatically tracked as you complete lessons and quizzes. You'll earn XP points, maintain streaks, and unlock achievements. Check the Progress section to see your learning analytics and milestones."
        ),
        FAQItem(
            id: "lives-system",
            question: "What are lives and how do they work?",
            answer: "Lives allow you to take quizzes and participate in learning activities. You start with 5 lives, and they regenerate over time. Lives are consumed when you take quizzes or make mistakes, encouraging thoughtful learning."
        ),
        FAQItem(
            id: "chatbot-feature",
            question: "How can I use the chatbot?",
            answer: "The chatbot is your AI companion for asking questions about the Bhagavad Gita, getting explanations of verses, or discussing spiritual concepts. It's designed to help deepen your understanding through conversation."
        ),
        FAQItem(
            id: "offline-access",
            question: "Can I use Dharma offline?",
            answer: "Currently, Dharma requires an internet connection to access lessons and sync your progress. We're working on offline capabilities for future updates."
        ),
        FAQItem(
            id: "account-settings",
            question: "How do I manage my account?",
            answer: "Visit the Profile section to update your display name, view your achievements, manage notification settings, and access your learning statistics. You can also sign out or delete your account from there."
        ),
        FAQItem(
            id: "technical-issues",
            question: "I'm experiencing technical issues. What should I do?",
            answer: "If you encounter any technical problems, please use the 'Report Issue' button in this help section to submit a detailed description. Our support team will review and address your concern promptly."
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Help & FAQ")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Find answers to common questions about Dharma")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // FAQ Items
                        VStack(spacing: 12) {
                            ForEach(faqItems) { item in
                                FAQItemView(
                                    item: item,
                                    isExpanded: expandedFAQ == item.id,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            expandedFAQ = expandedFAQ == item.id ? nil : item.id
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Still Need Help Section
                        VStack(spacing: 16) {
                            Text("Still need help?")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Can't find what you're looking for? We're here to help!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Contact Support") {
                                showingFeedback = true
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackSubmissionView()
        }
    }
}

struct FAQItem {
    let id: String
    let question: String
    let answer: String
}

extension FAQItem: Identifiable {}

struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(item.question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .padding(.horizontal)
                    
                    Text(item.answer)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    HelpFAQView()
}
