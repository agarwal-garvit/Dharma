//
//  Config.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation

struct Config {
    
    // MARK: - Hardcoded Configuration (for development)
    
    static var supabaseURL: String {
        return "https://cifjluhwhifwxiyzyrzx.supabase.co"
    }
    
    static var supabaseKey: String {
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpZmpsdWh3aGlmd3hpeXp5cnp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyNjQ2NTcsImV4cCI6MjA3NDg0MDY1N30.rAZ55o33qeVsYkFoooIZt3LMB-3d2c5-7e0GgqnG_B4"
    }
    
    static var openAIAPIKey: String {
        return "your_openai_api_key_here"
    }
    
    static var googleClientID: String {
        return "61300230049-q2pqdu6eikukd7frofkt4uuokf7u19jc.apps.googleusercontent.com"
    }
    
    // MARK: - Computed Properties
    
    static var supabaseURLObject: URL {
        return URL(string: supabaseURL)!
    }
    
    static var googleURLScheme: String {
        // Convert Google Client ID to URL scheme format
        // Example: 123456789-abcdefg.apps.googleusercontent.com -> com.googleusercontent.apps.123456789-abcdefg
        let components = googleClientID.components(separatedBy: ".")
        if components.count >= 3 {
            let reversedComponents = Array(components.reversed())
            return reversedComponents.joined(separator: ".")
        }
        return "com.googleusercontent.apps.\(googleClientID.replacingOccurrences(of: ".", with: "-"))"
    }
    
    // MARK: - Validation
    
    static func validateConfiguration() -> Bool {
        do {
            _ = supabaseURL
            _ = supabaseKey
            _ = openAIAPIKey
            _ = googleClientID
            _ = supabaseURLObject
            return true
        } catch {
            print("Configuration validation failed: \(error)")
            return false
        }
    }
    
    // MARK: - Debug Information (Remove in production)
    
    static func printConfigurationStatus() {
        print("=== Configuration Status ===")
        print("Supabase URL: \(supabaseURL)")
        print("Supabase Key: \(supabaseKey.prefix(20))...")
        print("OpenAI Key: \(openAIAPIKey.prefix(20))...")
        print("Google Client ID: \(googleClientID)")
        print("Google URL Scheme: \(googleURLScheme)")
        print("==========================")
    }
}
