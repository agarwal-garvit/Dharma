#!/usr/bin/env swift

// Configuration Verification Script
// Run this script to verify your environment variables are set correctly

import Foundation

print("🔍 Verifying Dharma App Configuration...")
print("=====================================")

// Check for required environment variables
let requiredVars = [
    "SUPABASE_URL",
    "SUPABASE_ANON_KEY", 
    "OPENAI_API_KEY",
    "GOOGLE_CLIENT_ID"
]

var allPresent = true

for varName in requiredVars {
    if let value = ProcessInfo.processInfo.environment[varName] {
        if value.isEmpty {
            print("❌ \(varName): Empty value")
            allPresent = false
        } else {
            // Mask sensitive values
            let maskedValue = varName.contains("KEY") || varName.contains("ID") ? 
                "\(value.prefix(10))..." : value
            print("✅ \(varName): \(maskedValue)")
        }
    } else {
        print("❌ \(varName): Not set")
        allPresent = false
    }
}

print("=====================================")

if allPresent {
    print("🎉 All environment variables are properly configured!")
    print("✅ Your app should work correctly with the current configuration.")
} else {
    print("⚠️  Some environment variables are missing or empty.")
    print("📋 Please check your .env file and Xcode build settings.")
    print("📖 See ENVIRONMENT_SETUP.md for detailed instructions.")
}

print("=====================================")
