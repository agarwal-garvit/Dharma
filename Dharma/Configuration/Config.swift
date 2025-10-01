//
//  Config.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation

struct Config {
    
    // MARK: - Environment Variables
    
    static var supabaseURL: String {
        guard let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] ??
                       Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            fatalError("SUPABASE_URL not found in environment variables or Info.plist")
        }
        return url
    }
    
    static var supabaseKey: String {
        guard let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ??
                       Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY not found in environment variables or Info.plist")
        }
        return key
    }
    
    static var openAIAPIKey: String {
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ??
                       Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("OPENAI_API_KEY not found in environment variables or Info.plist")
        }
        return key
    }
    
    static var googleClientID: String {
        guard let clientID = ProcessInfo.processInfo.environment["GOOGLE_CLIENT_ID"] ??
                            Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String else {
            fatalError("GOOGLE_CLIENT_ID not found in environment variables or Info.plist")
        }
        return clientID
    }
    
    // MARK: - Computed Properties
    
    static var supabaseURLObject: URL {
        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid SUPABASE_URL format")
        }
        return url
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
