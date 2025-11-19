//
//  AudioManager.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import Foundation
import AVFoundation
import SwiftUI

@Observable
class AudioManager: NSObject {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var currentSpeechUtterance: AVSpeechUtterance?
    
    var isPlaying = false
    var currentVerse: Verse?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Verse Audio Playback
    
    func playVerse(_ verse: Verse, language: String? = nil, customText: String? = nil) {
        currentVerse = verse
        
        // First try to play bundled audio file
        if let audioURL = verse.audioURL,
           let url = Bundle.main.url(forResource: audioURL.replacingOccurrences(of: "bundle://audio/", with: "").replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") {
            playAudioFile(url: url)
        } else {
            // Fallback to TTS with language context
            playVerseWithTTS(verse, language: language, customText: customText)
        }
    }
    
    private func playAudioFile(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play audio file: \(error)")
            // Fallback to TTS (default to Sanskrit)
            if let verse = currentVerse {
                playVerseWithTTS(verse, language: "sanskrit")
            }
        }
    }
    
    private func playVerseWithTTS(_ verse: Verse, language: String? = nil, customText: String? = nil) {
        // Stop any current speech/audio
        speechSynthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        
        // Use Cartesia API for TTS
        Task {
            do {
                try await playVerseWithCartesia(verse: verse, selectedLanguage: language, customText: customText)
            } catch {
                print("Cartesia TTS failed: \(error), falling back to system TTS")
                // Fallback to system TTS
                await MainActor.run {
                    playVerseWithSystemTTS(verse, customText: customText)
                }
            }
        }
    }
    
    private func playVerseWithCartesia(verse: Verse, selectedLanguage: String?, customText: String?) async throws {
        // Determine language and transcript based on selected language or custom text
        let (transcript, language): (String, String) = {
            // If custom text is provided (e.g., commentary), use it with English
            if let custom = customText, !custom.isEmpty {
                return (custom, "en")
            }
            
            // If language is provided, use it to determine transcript and language code
            if let lang = selectedLanguage {
                switch lang.lowercased() {
                case "sanskrit":
                    // Sanskrit: use IAST text with English language
                    return (verse.iastText, "en")
                case "hindi":
                    // Hindi: use Hindi translation with Hindi language
                    if let hindiText = verse.translationHi, !hindiText.isEmpty {
                        return (hindiText, "hi")
                    } else {
                        // Fallback to English if no Hindi translation
                        return (verse.translationEn, "en")
                    }
                case "english":
                    // English: use English translation with English language
                    return (verse.translationEn, "en")
                default:
                    // Default to IAST with English
                    return (verse.iastText, "en")
                }
            } else {
                // Default to IAST with English for Sanskrit pronunciation
                return (verse.iastText, "en")
            }
        }()
        
        // Cartesia API endpoint
        let url = URL(string: "https://api.cartesia.ai/tts/bytes")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("2025-04-16", forHTTPHeaderField: "Cartesia-Version")
        request.setValue(Config.cartesiaAPIKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request body matching Cartesia API format
        let requestBody: [String: Any] = [
            "model_id": "sonic-3",
            "transcript": transcript,
            "voice": [
                "mode": "id",
                "id": "28ca2041-5dda-42df-8123-f58ea9c3da00"
            ],
            "output_format": [
                "container": "wav",
                "encoding": "pcm_f32le",
                "sample_rate": 44100
            ],
            "language": language,
            "speed": "normal",
            "generation_config": [
                "speed": 0.9,
                "volume": 1
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AudioError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Cartesia API error (\(httpResponse.statusCode)): \(errorMessage)")
            throw AudioError.apiError
        }
        
        // Save audio data to temporary file and play
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")
        try data.write(to: tempURL)
        
        await MainActor.run {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.play()
                self.isPlaying = true
            } catch {
                print("Failed to play Cartesia audio: \(error)")
                // Fallback to system TTS
                self.playVerseWithSystemTTS(verse)
            }
        }
    }
    
    private func playVerseWithSystemTTS(_ verse: Verse, customText: String? = nil) {
        // Fallback to iOS system TTS
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Use custom text if provided, otherwise use IAST text
        let textToSpeak = customText ?? verse.iastText
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.rate = 0.4 // Slower for better pronunciation
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Best available voice
        
        currentSpeechUtterance = utterance
        speechSynthesizer.delegate = self
        speechSynthesizer.speak(utterance)
        isPlaying = true
    }
    
    func playWord(_ word: String) {
        // Stop any current audio
        stop()
        
        // Use system TTS for individual words (faster response)
        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = 0.3 // Even slower for individual words
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        currentSpeechUtterance = utterance
        speechSynthesizer.delegate = self
        speechSynthesizer.speak(utterance)
        isPlaying = true
    }
    
    func stop() {
        audioPlayer?.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        currentVerse = nil
        currentSpeechUtterance = nil
    }
    
    func pause() {
        audioPlayer?.pause()
        speechSynthesizer.pauseSpeaking(at: .immediate)
        isPlaying = false
    }
    
    func resume() {
        audioPlayer?.play()
        speechSynthesizer.continueSpeaking()
        isPlaying = true
    }
    
    // MARK: - Audio Settings
    
    func setPlaybackSpeed(_ speed: Float) {
        audioPlayer?.rate = speed
        // Note: AVSpeechSynthesizer doesn't support rate changes after creation
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
        // Note: AVSpeechSynthesizer volume is controlled by system volume
    }
}

// MARK: - Audio Errors

enum AudioError: Error, LocalizedError {
    case networkError
    case apiError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error occurred"
        case .apiError:
            return "API error occurred"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentVerse = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        isPlaying = false
        currentVerse = nil
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isPlaying = false
        currentVerse = nil
        currentSpeechUtterance = nil
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isPlaying = false
        currentVerse = nil
        currentSpeechUtterance = nil
    }
}
