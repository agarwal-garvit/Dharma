//
//  DailyShlokaContext.swift
//  Dharma
//
//  Created for embedding daily shloka context into AI conversations
//

import Foundation

struct DailyShlokaContext: Codable {
    let userName: String?
    let verseText: String
    let verseLocation: String
    let devanagariText: String
    let iastText: String
    let translationEn: String
    let translationHi: String?
    let commentaryShort: String?
    let reflectionPrompt: String?
    let userResponse: String?
    
    func toSystemMessage() -> String {
        var context = "You are a wise spiritual guide specializing in the Bhagavad Gita. Provide helpful, concise responses about Hindu philosophy and the Gita's teachings."
        
        if let name = userName {
            context += "\n\nThe user's name is \(name)."
        }
        
        context += "\n\nToday's Daily Shloka:\n"
        context += "Location: \(verseLocation)\n"
        context += "Devanagari: \(devanagariText)\n"
        context += "IAST: \(iastText)\n"
        context += "English Translation: \(translationEn)\n"
        
        if let hindi = translationHi, !hindi.isEmpty {
            context += "Hindi Translation: \(hindi)\n"
        }
        
        if let commentary = commentaryShort, !commentary.isEmpty {
            context += "\nCommentary: \(commentary)\n"
        }
        
        if let prompt = reflectionPrompt, !prompt.isEmpty {
            context += "\nReflection Prompt: \(prompt)\n"
        }
        
        if let response = userResponse, !response.isEmpty {
            context += "\nUser's Reflection Response: \(response)\n"
        }
        
        context += "\nPlease keep this daily shloka context in mind when responding to the user's questions. You can reference it naturally in your responses."
        
        return context
    }
}

