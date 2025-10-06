//
//  Config.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation

struct Config {
    
    // MARK: - Environment Variables from Build Settings
    
    static var supabaseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            fatalError("SUPABASE_URL not found in build settings")
        }
        return url
    }
    
    static var supabaseKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY not found in build settings")
        }
        return key
    }
    
    static var openAIAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("OPENAI_API_KEY not found in build settings")
        }
        return key
    }
    
    static var googleClientID: String {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String else {
            fatalError("GOOGLE_CLIENT_ID not found in build settings")
        }
        return clientID
    }
    
    static var googleURLScheme: String {
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_URL_SCHEME") as? String else {
            fatalError("GOOGLE_URL_SCHEME not found in build settings")
        }
        return scheme
    }
    
    // MARK: - Computed Properties
    
    static var supabaseURLObject: URL {
        return URL(string: supabaseURL)!
    }
    
    
    // MARK: - Validation
    
    static func validateConfiguration() -> Bool {
        _ = supabaseURL
        _ = supabaseKey
        _ = openAIAPIKey
        _ = googleClientID
        _ = googleURLScheme
        _ = supabaseURLObject
        return true
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
    
    static func debugInfoPlist() {
        print("=== Info.plist Debug ===")
        if let infoDict = Bundle.main.infoDictionary {
            print("All keys in Info.plist:")
            for key in infoDict.keys.sorted() {
                if key.contains("SUPABASE") || key.contains("OPENAI") || key.contains("GOOGLE") {
                    let value = infoDict[key] as? String ?? "nil"
                    let maskedValue = key.contains("KEY") || key.contains("ID") ? 
                        "\(value.prefix(10))..." : value
                    print("  \(key): \(maskedValue)")
                }
            }
        } else {
            print("No Info.plist found!")
        }
        print("========================")
    }
}
