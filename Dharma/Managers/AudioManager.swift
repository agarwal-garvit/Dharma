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
    
    func playVerse(_ verse: Verse) {
        currentVerse = verse
        
        // First try to play bundled audio file
        if let audioURL = verse.audioURL,
           let url = Bundle.main.url(forResource: audioURL.replacingOccurrences(of: "bundle://audio/", with: "").replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") {
            playAudioFile(url: url)
        } else {
            // Fallback to TTS
            playVerseWithTTS(verse)
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
            // Fallback to TTS
            if let verse = currentVerse {
                playVerseWithTTS(verse)
            }
        }
    }
    
    private func playVerseWithTTS(_ verse: Verse) {
        // Stop any current speech
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Create utterance for IAST text
        let utterance = AVSpeechUtterance(string: verse.iastText)
        utterance.rate = 0.4 // Slower for Sanskrit pronunciation
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Best available voice
        
        currentSpeechUtterance = utterance
        speechSynthesizer.delegate = self
        speechSynthesizer.speak(utterance)
        isPlaying = true
    }
    
    func playWord(_ word: String) {
        // Stop any current audio
        stop()
        
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
