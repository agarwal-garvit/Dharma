//
//  ReviewView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct ReviewView: View {
    @State private var dataManager = DataManager.shared
    @State private var reviewSessionManager = ReviewSessionManager()
    @State private var showingReviewSession = false
    
    private var dueItems: [ReviewItem] {
        dataManager.getDueReviewItems()
    }
    
    private var overdueItems: [ReviewItem] {
        let manager = SpacedRepetitionManager()
        return manager.getOverdueItems(dataManager.reviewItems)
    }
    
    private var upcomingItems: [ReviewItem] {
        let manager = SpacedRepetitionManager()
        return manager.getUpcomingItems(dataManager.reviewItems)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Due items section
                    if !dueItems.isEmpty {
                        dueItemsSection
                    }
                    
                    // Overdue items section
                    if !overdueItems.isEmpty {
                        overdueItemsSection
                    }
                    
                    // Upcoming items section
                    if !upcomingItems.isEmpty {
                        upcomingItemsSection
                    }
                    
                    // Empty state
                    if dueItems.isEmpty && overdueItems.isEmpty {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.large)
        }
        .fullScreenCover(isPresented: $showingReviewSession) {
            if let session = reviewSessionManager.currentSession {
                ReviewSessionView(session: session) {
                    showingReviewSession = false
                    reviewSessionManager.endSession()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Due Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(dueItems.count)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(dataManager.reviewItems.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            if !dueItems.isEmpty {
                Button("Start Review") {
                    startReviewSession()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var dueItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Due Today")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(dueItems.prefix(5)) { item in
                    ReviewItemRow(item: item, isDue: true)
                }
                
                if dueItems.count > 5 {
                    Text("And \(dueItems.count - 5) more items...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    private var overdueItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overdue")
                .font(.headline)
                .foregroundColor(.red)
            
            LazyVStack(spacing: 12) {
                ForEach(overdueItems.prefix(3)) { item in
                    ReviewItemRow(item: item, isDue: true, isOverdue: true)
                }
            }
        }
    }
    
    private var upcomingItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coming Up")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(upcomingItems.prefix(3)) { item in
                    ReviewItemRow(item: item, isDue: false)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("All Caught Up!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("No items due for review today. Great job staying consistent!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add More Items") {
                // Navigate to search or lessons to add items
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
    }
    
    private func startReviewSession() {
        reviewSessionManager.startSession(items: dueItems)
        showingReviewSession = true
    }
}

struct ReviewItemRow: View {
    let item: ReviewItem
    let isDue: Bool
    let isOverdue: Bool
    
    @State private var dataManager = DataManager.shared
    
    init(item: ReviewItem, isDue: Bool, isOverdue: Bool = false) {
        self.item = item
        self.isDue = isDue
        self.isOverdue = isOverdue
    }
    
    private var verse: Verse? {
        if item.kind == .verse {
            return dataManager.getVerse(by: item.payloadRef)
        }
        return nil
    }
    
    private var timeUntilDue: String {
        let now = Date()
        let timeInterval = item.nextDueAt.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return "Now"
        } else if timeInterval < 3600 { // Less than 1 hour
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m"
        } else if timeInterval < 86400 { // Less than 1 day
            let hours = Int(timeInterval / 3600)
            return "\(hours)h"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Item type icon
            ZStack {
                Circle()
                    .fill(itemColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: itemIcon)
                    .foregroundColor(.white)
                    .font(.caption)
            }
            
            // Item content
            VStack(alignment: .leading, spacing: 4) {
                if let verse = verse {
                    Text("Verse \(verse.reference)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(verse.translationEn)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("Review Item")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Box \(item.box)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if isDue {
                        Text(isOverdue ? "Overdue" : "Due now")
                            .font(.caption2)
                            .foregroundColor(isOverdue ? .red : .orange)
                    } else {
                        Text("Due in \(timeUntilDue)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private var itemColor: Color {
        if isOverdue {
            return .red
        } else if isDue {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var itemIcon: String {
        switch item.kind {
        case .verse:
            return "book.fill"
        case .word:
            return "textformat.abc"
        case .qa:
            return "questionmark.circle.fill"
        }
    }
}

struct ReviewSessionView: View {
    @State private var session: ReviewSession
    let onComplete: () -> Void
    @State private var dataManager = DataManager.shared
    @State private var showingAnswer = false
    @State private var userAnswer = ""
    @State private var isCorrect = false
    
    init(session: ReviewSession, onComplete: @escaping () -> Void) {
        self._session = State(initialValue: session)
        self.onComplete = onComplete
    }
    
    private var currentItem: ReviewItem? {
        session.currentItem
    }
    
    private var verse: Verse? {
        guard let item = currentItem,
              item.kind == .verse else { return nil }
        return dataManager.getVerse(by: item.payloadRef)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: session.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .padding(.horizontal)
                    .padding(.top)
                
                if session.isComplete {
                    sessionCompleteView
                } else if let item = currentItem, let verse = verse {
                    reviewItemView(item: item, verse: verse)
                } else {
                    Text("No items to review")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Review Session")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        onComplete()
                    }
                }
            }
        }
    }
    
    private var sessionCompleteView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Review Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Great job! You've completed your review session.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Done") {
                onComplete()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func reviewItemView(item: ReviewItem, verse: Verse) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Verse display
                VStack(alignment: .leading, spacing: 16) {
                    Text("Verse \(verse.reference)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    // Show verse text based on user preference
                    if dataManager.userPreferences.scriptDisplay == .devanagari || dataManager.userPreferences.scriptDisplay == .both {
                        Text(verse.devanagariText)
                            .font(.title2)
                            .fontWeight(.medium)
                            .lineSpacing(4)
                    }
                    
                    if dataManager.userPreferences.scriptDisplay == .iast || dataManager.userPreferences.scriptDisplay == .both {
                        Text(verse.iastText)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                    }
                    
                    if showingAnswer {
                        Text(verse.translationEn)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(2)
                            .transition(.opacity)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                // Audio button
                Button(action: {
                    AudioManager.shared.playVerse(verse)
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Play Audio")
                            .font(.headline)
                    }
                    .foregroundColor(.orange)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Answer section
                if !showingAnswer {
                    Button("Show Answer") {
                        withAnimation {
                            showingAnswer = true
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    VStack(spacing: 16) {
                        Text("How well did you know this?")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            Button("Again") {
                                submitAnswer(wasCorrect: false)
                            }
                            .buttonStyle(ReviewButtonStyle(color: .red))
                            
                            Button("Hard") {
                                submitAnswer(wasCorrect: false)
                            }
                            .buttonStyle(ReviewButtonStyle(color: .orange))
                            
                            Button("Good") {
                                submitAnswer(wasCorrect: true)
                            }
                            .buttonStyle(ReviewButtonStyle(color: .green))
                            
                            Button("Easy") {
                                submitAnswer(wasCorrect: true)
                            }
                            .buttonStyle(ReviewButtonStyle(color: .blue))
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func submitAnswer(wasCorrect: Bool) {
        guard let item = currentItem else { return }
        
        dataManager.submitReviewAnswer(for: item, wasCorrect: wasCorrect)
        
        // Move to next item
        var updatedSession = session
        _ = updatedSession.submitAnswer("", for: item)
        session = updatedSession
        
        showingAnswer = false
        
        // Provide haptic feedback
        if wasCorrect {
            HapticManager.shared.correctAnswer()
        } else {
            HapticManager.shared.incorrectAnswer()
        }
    }
}

struct ReviewButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ReviewView()
}
