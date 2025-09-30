//
//  SpacedRepetition.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import Combine

// MARK: - Spaced Repetition System (Leitner Boxes)

class SpacedRepetitionManager: ObservableObject {
    private let intervals = [1, 3, 7, 14, 30] // days
    
    func scheduleNext(item: inout ReviewItem, wasCorrect: Bool, now: Date = Date()) {
        if wasCorrect {
            item.box = min(item.box + 1, 5)
        } else {
            item.box = 1
        }
        
        let days = intervals[item.box - 1]
        item.lastReviewedAt = now
        
        if wasCorrect {
            item.nextDueAt = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        } else {
            // If incorrect, schedule for later today (in 4 hours)
            item.nextDueAt = Calendar.current.date(byAdding: .hour, value: 4, to: now) ?? now
        }
    }
    
    func getDueItems(_ items: [ReviewItem]) -> [ReviewItem] {
        let now = Date()
        return items.filter { item in
            item.nextDueAt <= now
        }.sorted { $0.nextDueAt < $1.nextDueAt }
    }
    
    func getOverdueItems(_ items: [ReviewItem]) -> [ReviewItem] {
        let now = Date()
        return items.filter { item in
            item.nextDueAt < now
        }.sorted { $0.nextDueAt < $1.nextDueAt }
    }
    
    func getUpcomingItems(_ items: [ReviewItem], withinDays: Int = 7) -> [ReviewItem] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: withinDays, to: now) ?? now
        
        return items.filter { item in
            item.nextDueAt > now && item.nextDueAt <= futureDate
        }.sorted { $0.nextDueAt < $1.nextDueAt }
    }
}

// MARK: - Review Session Manager

class ReviewSessionManager: ObservableObject {
    @Published var currentSession: ReviewSession?
    @Published var isActive = false
    
    func startSession(items: [ReviewItem]) {
        currentSession = ReviewSession(items: items)
        isActive = true
    }
    
    func endSession() {
        currentSession = nil
        isActive = false
    }
    
    func submitAnswer(_ answer: String, for item: ReviewItem) -> Bool {
        guard var session = currentSession else { return false }
        return session.submitAnswer(answer, for: item)
    }
}

struct ReviewSession {
    let items: [ReviewItem]
    private var currentIndex = 0
    private var results: [String: Bool] = [:]
    
    init(items: [ReviewItem]) {
        self.items = items
    }
    
    var currentItem: ReviewItem? {
        guard currentIndex < items.count else { return nil }
        return items[currentIndex]
    }
    
    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(currentIndex) / Double(items.count)
    }
    
    var isComplete: Bool {
        currentIndex >= items.count
    }
    
    mutating func submitAnswer(_ answer: String, for item: ReviewItem) -> Bool {
        // This is a simplified version - in a real app, you'd have more sophisticated answer checking
        let isCorrect = !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        results[item.id] = isCorrect
        currentIndex += 1
        return isCorrect
    }
    
    func getResults() -> [String: Bool] {
        return results
    }
}
