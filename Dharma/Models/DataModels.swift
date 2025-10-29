//
//  DataModels.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation

// MARK: - Core Data Models

enum SacredTextType: String, Codable, CaseIterable {
    case bhagavadGita = "bhagavad_gita"
    case ramayana = "ramayana"
    case mahabharata = "mahabharata"
    case upanishads = "upanishads"
    case vedas = "vedas"
    
    var displayName: String {
        switch self {
        case .bhagavadGita: return "Bhagavad Gita"
        case .ramayana: return "Ramayana"
        case .mahabharata: return "Mahabharata"
        case .upanishads: return "Upanishads"
        case .vedas: return "Vedas"
        }
    }
    
    var description: String {
        switch self {
        case .bhagavadGita: return "The Song of God - 700 verses of spiritual wisdom"
        case .ramayana: return "The Epic of Rama - Journey of dharma and devotion"
        case .mahabharata: return "The Great Epic - Including the Bhagavad Gita"
        case .upanishads: return "Philosophical texts - The essence of Vedic wisdom"
        case .vedas: return "Ancient scriptures - The foundation of Hindu philosophy"
        }
    }
    
    var icon: String {
        switch self {
        case .bhagavadGita: return "book.closed"
        case .ramayana: return "book.pages"
        case .mahabharata: return "books.vertical"
        case .upanishads: return "lightbulb"
        case .vedas: return "scroll"
        }
    }
}

struct SacredText: Identifiable, Codable {
    let id: String
    let type: SacredTextType
    let title: String
    let description: String
    let totalChapters: Int
    let totalVerses: Int
    let isAvailable: Bool
    
    init(type: SacredTextType) {
        self.id = type.rawValue
        self.type = type
        self.title = type.displayName
        self.description = type.description
        self.isAvailable = type == .bhagavadGita // Only Bhagavad Gita is available for now
        
        // Set chapter and verse counts based on text type
        switch type {
        case .bhagavadGita:
            self.totalChapters = 18
            self.totalVerses = 700
        case .ramayana:
            self.totalChapters = 7
            self.totalVerses = 24000
        case .mahabharata:
            self.totalChapters = 18
            self.totalVerses = 200000
        case .upanishads:
            self.totalChapters = 108
            self.totalVerses = 1000
        case .vedas:
            self.totalChapters = 4
            self.totalVerses = 20000
        }
    }
}

struct Chapter: Identifiable, Codable {
    let id: String
    let index: Int
    let titleEn: String
    let titleSa: String
    
    enum CodingKeys: String, CodingKey {
        case id, index
        case titleEn = "title_en"
        case titleSa = "title_sa"
    }
}

struct Verse: Identifiable, Codable {
    let id: String
    let chapterIndex: Int
    let verseIndex: Int
    let devanagariText: String
    let iastText: String
    let translationEn: String
    let keywords: [String]
    let audioURL: String?
    let commentaryShort: String?
    let themes: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case chapterIndex = "chapter_index"
        case verseIndex = "verse_index"
        case devanagariText = "devanagari_text"
        case iastText = "iast_text"
        case translationEn = "translation_en"
        case keywords
        case audioURL = "audio_url"
        case commentaryShort = "commentary_short"
        case themes
    }
    
    var reference: String {
        "\(chapterIndex).\(verseIndex)"
    }
}

struct Lesson: Identifiable, Codable, Equatable {
    let id: String
    let unitId: String
    let title: String
    let objective: String
    let exerciseIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case unitId = "unit_id"
        case title, objective
        case exerciseIds = "exercise_ids"
    }
}

enum ExerciseType: String, Codable, CaseIterable {
    case readReveal = "read_reveal"
    case match = "match"
    case fillBlank = "fill_blank"
    case orderTokens = "order_tokens"
    case multipleChoice = "multiple_choice"
    case listening = "listening"
    
    var displayName: String {
        switch self {
        case .readReveal: return "Read & Reveal"
        case .match: return "Match"
        case .fillBlank: return "Fill in the Blank"
        case .orderTokens: return "Order the Verse"
        case .multipleChoice: return "Multiple Choice"
        case .listening: return "Listening"
        }
    }
}

struct Exercise: Identifiable, Codable {
    let id: String
    let type: ExerciseType
    let prompt: String
    let options: [String]?
    let correctAnswer: String?
    let hints: [String]?
    let assetRefs: [String]?
    let verseRefs: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, type, prompt, options
        case correctAnswer = "correct_answer"
        case hints
        case assetRefs = "asset_refs"
        case verseRefs = "verse_refs"
    }
}

// MARK: - User Progress Models

struct UserProgress: Codable {
    var streak: Int
    var totalXP: Int
    var hearts: Int
    var completedLessons: Set<String>
    var completedUnits: Set<String>
    var lastStudyDate: Date?
    
    init() {
        self.streak = 0
        self.totalXP = 0
        self.hearts = 5
        self.completedLessons = []
        self.completedUnits = []
        self.lastStudyDate = nil
    }
}

enum ReviewItemKind: String, Codable {
    case word = "word"
    case verse = "verse"
    case qa = "qa"
}

struct ReviewItem: Identifiable, Codable {
    let id: String
    let kind: ReviewItemKind
    let payloadRef: String
    var box: Int
    var lastReviewedAt: Date?
    var nextDueAt: Date
    var ease: Double
    
    init(id: String, kind: ReviewItemKind, payloadRef: String) {
        self.id = id
        self.kind = kind
        self.payloadRef = payloadRef
        self.box = 1
        self.lastReviewedAt = nil
        self.nextDueAt = Date()
        self.ease = 2.5
    }
}

// MARK: - User Preferences

enum ScriptDisplay: String, Codable, CaseIterable {
    case devanagari = "devanagari"
    case iast = "iast"
    case both = "both"
    
    var displayName: String {
        switch self {
        case .devanagari: return "Devanagari"
        case .iast: return "IAST"
        case .both: return "Both"
        }
    }
}

struct UserPreferences: Codable {
    var scriptDisplay: ScriptDisplay
    var preferredLanguage: String
    var fontSize: Double
    var playbackSpeed: Double
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var notificationsEnabled: Bool
    var studyTime: Date
    
    init() {
        self.scriptDisplay = .both
        self.preferredLanguage = "en"
        self.fontSize = 1.0
        self.playbackSpeed = 1.0
        self.soundEnabled = true
        self.hapticsEnabled = true
        self.notificationsEnabled = true
        self.studyTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }
}

// MARK: - Chat Models

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let conversationId: UUID?
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), conversationId: UUID? = nil, content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.conversationId = conversationId
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// Database-specific model for chat messages
struct ChatMessageForDB: Codable {
    let id: UUID
    let conversationId: UUID?
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case content
        case isUser = "is_user"
        case timestamp
    }
}

struct ChatConversation: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let messageCount: Int
    
    init(id: UUID = UUID(), userId: UUID, title: String, createdAt: Date = Date(), updatedAt: Date = Date(), messageCount: Int = 0) {
        self.id = id
        self.userId = userId
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messageCount = messageCount
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case messageCount = "message_count"
    }
}

// MARK: - Seed Data Structure

struct SeedData: Codable {
    let chapters: [Chapter]
    let verses: [Verse]
    let lessons: [Lesson]
    let exercises: [Exercise]
}

// MARK: - Shloka Content Model

struct ShlokaContent {
    let location: String
    let script: String
    let transliteration: String
    let translation: String
    
    init?(from content: [String: AnyCodable]?) {
        guard let content = content,
              let location = content["location"]?.value as? String,
              let script = content["script"]?.value as? String,
              let transliteration = content["transliteration"]?.value as? String,
              let translation = content["translation"]?.value as? String else {
            return nil
        }
        
        self.location = location.replacingOccurrences(of: "\\n", with: "\n")
        self.script = script.replacingOccurrences(of: "\\n", with: "\n")
        self.transliteration = transliteration.replacingOccurrences(of: "\\n", with: "\n")
        self.translation = translation.replacingOccurrences(of: "\\n", with: "\n")
    }
}
