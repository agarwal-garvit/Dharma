//
//  DailyView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 10/22/25.
//

import SwiftUI
import Supabase

enum VerseLanguage: String, CaseIterable {
    case sanskrit = "Sanskrit"
    case hindi = "Hindi"
    case english = "English"
}

struct DailyView: View {
    @State private var dailyVerse: Verse?
    @State private var dailyVerseData: DBDailyVerse?
    @State private var isLoading = true
    @State private var currentDate = Date()
    @State private var livesManager = LivesManager.shared
    @State private var isFlipped = false
    @State private var selectedLanguage: VerseLanguage = .english
    @State private var preferredLanguage: VerseLanguage = .english
    @State private var userMetrics: DBUserMetrics?
    @State private var showLanguageSettings = false
    @State private var audioManager = AudioManager.shared
    @State private var reflectionText: String = ""
    @State private var isFavorite: Bool = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: currentDate)
    }
    
    var body: some View {
        ZStack {
            // Futuristic gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.08, green: 0.08, blue: 0.18),
                    Color(red: 0.12, green: 0.10, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
        ScrollView {
            VStack(spacing: 0) {
                    // Header with streak and settings
                headerSection
                        .padding(.top, 20)
                
                    if isLoading {
                        loadingView
                            .padding(.top, 100)
                    } else if let verse = dailyVerse {
                        VStack(spacing: 24) {
                            // Flip Card
                            flipCard(verse: verse)
                                .padding(.top, 40)
                                .padding(.horizontal, 24)
                            
                            // Reflection Card
                            if let verseData = dailyVerseData, let reflectionPrompt = verseData.reflectionPrompt, !reflectionPrompt.isEmpty {
                                reflectionCard(prompt: reflectionPrompt)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 32)
                            }
                        }
                    } else {
                        emptyStateView
                            .padding(.top, 100)
                    }
                }
            }
        }
        .onAppear {
            loadDailyVerse()
            loadUserMetrics()
            loadUserDailyLanguage()
            
            // Check and regenerate lives
            Task {
                await livesManager.checkAndRegenerateLives()
            }
        }
        .sheet(isPresented: $showLanguageSettings) {
            languageSettingsSheet
        }
    }
    
    private var headerSection: some View {
        HStack {
            // Left side - Title and Date
            VStack(alignment: .leading, spacing: 8) {
                // Date with futuristic styling
                Text(formattedDate.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(2)
                
                // Title with bold, modern font
                Text("DAILY SHLOKA")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .tracking(3)
            }
            
            Spacer()
            
            // Right side - Streak and Settings
            VStack(alignment: .trailing, spacing: 12) {
                // Streak display
                if let metrics = userMetrics {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("\(metrics.currentStreak)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("DAY")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(1)
                    }
                }
                
                // Language preference button
                Button(action: {
                    showLanguageSettings = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                            .font(.system(size: 14, weight: .semibold))
                        Text(preferredLanguage.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                    )
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var languageSettingsSheet: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.08, green: 0.08, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("LANGUAGE PREFERENCE")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    Text("Choose your default language")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 40)
                
                // Language options
                VStack(spacing: 16) {
                    ForEach(VerseLanguage.allCases, id: \.self) { language in
                        Button(action: {
                            Task {
                                await updateUserDailyLanguage(language: language)
                            }
                            preferredLanguage = language
                            selectedLanguage = language
                            showLanguageSettings = false
                        }) {
            HStack {
                                Text(language.rawValue)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if preferredLanguage == language {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.8, green: 0.6, blue: 1.0)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(preferredLanguage == language ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        preferredLanguage == language ?
                                        LinearGradient(
                                            colors: [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.8, green: 0.6, blue: 1.0)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) : LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing),
                                        lineWidth: preferredLanguage == language ? 2 : 1
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
    
    private func flipCard(verse: Verse) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Front of card (Verse)
                if !isFlipped {
                    cardFront(verse: verse)
                        .rotation3DEffect(
                            .degrees(isFlipped ? 180 : 0),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .opacity(isFlipped ? 0 : 1)
                }
                
                // Back of card (Details)
                if isFlipped {
                    cardBack(verse: verse)
                        .rotation3DEffect(
                            .degrees(isFlipped ? 0 : -180),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .opacity(isFlipped ? 1 : 0)
                }
            }
            .frame(height: geometry.size.width * 1.5)
        }
        .frame(height: UIScreen.main.bounds.width * 1.5)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
    
    private func cardFront(verse: Verse) -> some View {
        ZStack {
            // Futuristic card background with glow
            RoundedRectangle(cornerRadius: 32)
                .fill(
                LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.15, blue: 0.25),
                            Color(red: 0.20, green: 0.18, blue: 0.30),
                            Color(red: 0.18, green: 0.16, blue: 0.28)
                        ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.purple.opacity(0.3), radius: 30, x: 0, y: 15)
                .shadow(color: Color.blue.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 0) {
                // Top bar with play audio and flip hint
                HStack {
                    // Play audio button (top left)
                    Button(action: {
                        if audioManager.isPlaying && audioManager.currentVerse?.id == verse.id {
                            audioManager.stop()
                        } else {
                            audioManager.playVerse(verse, language: selectedLanguage.rawValue)
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying && audioManager.currentVerse?.id == verse.id ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Flip hint (top right)
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 10, weight: .semibold))
                        Text("TAP TO FLIP")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Main verse text - changes based on selected language
                Text(verseText(for: verse, language: selectedLanguage))
                    .font(fontForLanguage(selectedLanguage))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 32)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                
                Spacer()
                
                // Language selector bar (smaller)
                languageSelectorBar
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
            }
        }
    }
    
    private var languageSelectorBar: some View {
        HStack(spacing: 0) {
            ForEach(VerseLanguage.allCases, id: \.self) { language in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedLanguage = language
                    }
                }) {
                    Text(language.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(selectedLanguage == language ? .white : .white.opacity(0.5))
                        .tracking(0.5)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedLanguage == language ?
                            LinearGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.3),
                                    Color(red: 0.8, green: 0.6, blue: 1.0).opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                        )
                }
            }
        }
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func verseText(for verse: Verse, language: VerseLanguage) -> String {
        switch language {
        case .sanskrit:
            return verse.devanagariText
        case .hindi:
            // Only use Hindi translation from database, show nothing if blank
            return verse.translationHi ?? ""
        case .english:
            return verse.translationEn
        }
    }
    
    private func fontForLanguage(_ language: VerseLanguage) -> Font {
        switch language {
        case .sanskrit:
            return .system(size: 28, weight: .medium, design: .default)
        case .hindi:
            return .system(size: 24, weight: .regular, design: .serif)
        case .english:
            return .system(size: 28, weight: .bold, design: .serif)
        }
    }
    
    private func cardBack(verse: Verse) -> some View {
        ZStack {
            // Back card background
            RoundedRectangle(cornerRadius: 32)
                .fill(
            LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.18, blue: 0.30),
                            Color(red: 0.15, green: 0.15, blue: 0.25),
                            Color(red: 0.18, green: 0.16, blue: 0.28)
                        ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.purple.opacity(0.3), radius: 30, x: 0, y: 15)
                .shadow(color: Color.blue.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 0) {
                // Top bar with play audio and return hint
                HStack {
                    // Play audio button (top left)
                    Button(action: {
                        if audioManager.isPlaying && audioManager.currentVerse?.id == verse.id {
                            audioManager.stop()
                        } else {
                            // Play the commentary text on the back of the card
                            let commentaryText = verse.commentaryShort ?? "This verse speaks to the eternal wisdom of dharma and the path of righteousness. Through regular contemplation of these teachings, we develop clarity in our thoughts and actions."
                            audioManager.playVerse(verse, language: "english", customText: commentaryText)
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying && audioManager.currentVerse?.id == verse.id ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Return hint (top right)
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 10, weight: .semibold))
                        Text("TAP TO RETURN")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Verse Location
                        VStack(spacing: 8) {
                            if let verseData = dailyVerseData {
                                if let sacredText = verseData.sacredText, !sacredText.isEmpty {
                                    Text(sacredText.uppercased())
                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.8, green: 0.6, blue: 1.0)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                
                                if let verseLocation = verseData.verseLocation, !verseLocation.isEmpty {
                                    Text(verseLocation)
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                        .tracking(3)
                                } else {
                                    // Fallback to chapter.verse if verse_location is not available
                                    Text("\(verse.chapterIndex).\(verse.verseIndex)")
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                        .tracking(3)
                                }
                            } else {
                                // Fallback if no verse data
                                Text("\(verse.chapterIndex).\(verse.verseIndex)")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                                    .tracking(3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 32)
                    
                    // Explanation/Commentary
                    if let commentary = verse.commentaryShort, !commentary.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EXPLANATION")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(2)
                            
                            Text(commentary)
                                .font(.system(size: 17, weight: .regular, design: .default))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(8)
                        }
                        .padding(.horizontal, 32)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EXPLANATION")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(2)
                            
                            Text("This verse speaks to the eternal wisdom of dharma and the path of righteousness. Through regular contemplation of these teachings, we develop clarity in our thoughts and actions.")
                                .font(.system(size: 17, weight: .regular, design: .default))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(8)
                        }
                        .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white.opacity(0.6))
            
            Text("LOADING WISDOM...")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .tracking(2)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white.opacity(0.4))
            
            Text("NO WISDOM AVAILABLE")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .tracking(2)
        }
    }
    
    private func reflectionCard(prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.8, green: 0.6, blue: 1.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("REFLECTION")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(2)
            }
            
            // Prompt
            Text(prompt)
                .font(.system(size: 17, weight: .regular, design: .default))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(6)
            
            // Text input
            ZStack(alignment: .topLeading) {
                if reflectionText.isEmpty {
                    Text("Share your thoughts...")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $reflectionText)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(8)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            
            // Action buttons
            HStack(spacing: 12) {
                // Favorite button
                Button(action: {
                    isFavorite.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .semibold))
                        Text(isFavorite ? "FAVORITED" : "FAVORITE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundColor(isFavorite ? .pink : .white.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(isFavorite ? Color.pink.opacity(0.2) : Color.white.opacity(0.1))
                    )
                    .overlay(
                        Capsule()
                            .stroke(isFavorite ? Color.pink.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                
                Spacer()
                
                // Save button
                Button(action: {
                    // Save functionality will be implemented later
                    print("Saving reflection...")
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("SAVE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.8, green: 0.6, blue: 1.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.15, blue: 0.25),
                            Color(red: 0.20, green: 0.18, blue: 0.30),
                            Color(red: 0.18, green: 0.16, blue: 0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.purple.opacity(0.3), radius: 30, x: 0, y: 15)
        .shadow(color: Color.blue.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func loadUserMetrics() {
        Task {
            let authManager = DharmaAuthManager.shared
            let metrics = await authManager.getUserMetrics()
            await MainActor.run {
                self.userMetrics = metrics
            }
        }
    }
    
    private func loadUserDailyLanguage() {
        Task {
            let authManager = DharmaAuthManager.shared
            guard let userId = authManager.user?.id else {
                // If not authenticated, use default
                await MainActor.run {
                    self.preferredLanguage = .english
                    self.selectedLanguage = .english
                }
                return
            }
            
            do {
                let databaseService = DatabaseService.shared
                if let languageString = try await databaseService.getUserDailyLanguage(userId: userId),
                   let language = VerseLanguage(rawValue: languageString) {
                    await MainActor.run {
                        self.preferredLanguage = language
                        self.selectedLanguage = language
                    }
                } else {
                    // No preference set, use default
                    await MainActor.run {
                        self.preferredLanguage = .english
                        self.selectedLanguage = .english
                    }
                }
            } catch {
                print("Error loading user daily language: \(error)")
                // On error, use default
                await MainActor.run {
                    self.preferredLanguage = .english
                    self.selectedLanguage = .english
                }
            }
        }
    }
    
    private func updateUserDailyLanguage(language: VerseLanguage) async {
        let authManager = DharmaAuthManager.shared
        guard let userId = authManager.user?.id else {
            // If not authenticated, just update local state
            await MainActor.run {
                self.preferredLanguage = language
                self.selectedLanguage = language
            }
            return
        }
        
        do {
            let databaseService = DatabaseService.shared
            try await databaseService.updateUserDailyLanguage(userId: userId, language: language.rawValue)
            await MainActor.run {
                self.preferredLanguage = language
                self.selectedLanguage = language
            }
        } catch {
            print("Error updating user daily language: \(error)")
            // Still update local state even if database update fails
            await MainActor.run {
                self.preferredLanguage = language
                self.selectedLanguage = language
            }
        }
    }
    
    private func loadDailyVerse() {
        Task {
            // Simulate loading
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            do {
                let databaseService = DatabaseService.shared
                
                // First try to get verse for today's date
                if let dailyVerse = try await databaseService.fetchDailyVerse(for: currentDate) {
                    await MainActor.run {
                        self.dailyVerseData = dailyVerse
                        self.dailyVerse = dailyVerse.toVerse()
                        self.isLoading = false
                    }
                    return
                }
                
                // If no verse for today, try to get by day of year (cycling through available verses)
                let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: currentDate) ?? 1
                if let dailyVerse = try await databaseService.fetchDailyVerseByDayOfYear(dayOfYear: dayOfYear) {
                    await MainActor.run {
                        self.dailyVerseData = dailyVerse
                        self.dailyVerse = dailyVerse.toVerse()
                        self.isLoading = false
                    }
                    return
                }
                
                // If still no verse, try to get the next available verse
                if let dailyVerse = try await databaseService.fetchNextDailyVerse() {
                    await MainActor.run {
                        self.dailyVerseData = dailyVerse
                        self.dailyVerse = dailyVerse.toVerse()
                        self.isLoading = false
                    }
                    return
                }
                
                // Fallback to sample verse if no database verses are available
                await MainActor.run {
                    self.dailyVerse = createSampleVerse(dayOfYear: dayOfYear)
                    self.dailyVerseData = nil // No database data for sample
                    self.isLoading = false
                }
                
            } catch {
                print("Error loading daily verse from database: \(error)")
                
                // Fallback to sample verse on error
                let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: currentDate) ?? 1
                await MainActor.run {
                    self.dailyVerse = createSampleVerse(dayOfYear: dayOfYear)
                    self.dailyVerseData = nil // No database data for sample
                    self.isLoading = false
                }
            }
        }
    }
    
    private func createSampleVerse(dayOfYear: Int) -> Verse {
        // Sample verses for demonstration
        let sampleVerses: [(devanagari: String, iast: String, translation: String, chapter: Int, verse: Int, keywords: [String], themes: [String], commentary: String)] = [
            (
                "दृष्ट्वेमं स्वजनं कृष्ण युयुत्सुं समुपस्थितम्।\nसीदन्ति मम गात्राणि मुखं च परिशुष्यति॥",
                "dṛṣṭvemaṁ sva-janaṁ kṛṣṇa yuyutsuṁ samupasthitam\nsīdanti mama gātrāṇi mukhaṁ ca pariśuṣyati",
                "Seeing my own kinsmen arrayed for battle, O Krishna, my limbs give way and my mouth is parched.",
                1, 28,
                ["Moral Dilemma", "Family", "Duty", "Compassion", "Arjuna's Despair"],
                ["Ethical Conflict", "Dharma vs. Love", "Inner Turmoil", "Spiritual Crisis"],
                "This verse captures Arjuna's profound moral crisis on the battlefield of Kurukshetra. Faced with the prospect of fighting his own relatives and teachers, Arjuna experiences physical and emotional breakdown, setting the stage for Krishna's teachings on dharma and the nature of the self."
            ),
            (
                "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥",
                "karmaṇy-evādhikāras te mā phaleṣu kadācana\nmā karma-phala-hetur bhūr mā te saṅgo 'stvakarmaṇi",
                "You have a right to perform your prescribed duty, but you are not entitled to the fruits of action. Never consider yourself the cause of the results of your activities, and never be attached to not doing your duty.",
                2, 47,
                ["Karma", "Duty", "Detachment", "Action"],
                ["Selfless Action", "Dharma", "Non-attachment"],
                "This verse teaches the essence of Karma Yoga - performing one's duty without attachment to results. It emphasizes focusing on the action itself rather than its outcomes, which leads to inner peace and spiritual growth."
            ),
            (
                "योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय।\nसिद्ध्यसिद्ध्योः समो भूत्वा समत्वं योग उच्यते॥",
                "yoga-sthaḥ kuru karmāṇi saṅgaṁ tyaktvā dhanañjaya\nsiddhy-asiddhyoḥ samo bhūtvā samatvaṁ yoga ucyate",
                "Perform your duty equipoised, O Arjuna, abandoning all attachment to success or failure. Such equanimity is called Yoga.",
                2, 48,
                ["Yoga", "Equanimity", "Balance", "Detachment"],
                ["Mental Peace", "Steadiness", "Inner Strength"],
                "True yoga is maintaining equanimity in all situations. This verse teaches us to remain balanced whether we succeed or fail, as this mental steadiness is the foundation of spiritual practice."
            ),
            (
                "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम्॥",
                "yadā yadā hi dharmasya glānir bhavati bhārata\nabhyutthānam adharmasya tadātmānaṁ sṛjāmy aham",
                "Whenever there is a decline in righteousness and an increase in unrighteousness, O Arjuna, at that time I manifest Myself.",
                4, 7,
                ["Dharma", "Divine", "Protection", "Righteousness"],
                ["Divine Intervention", "Justice", "Cosmic Order"],
                "This verse assures us that the divine always protects dharma. Whenever evil becomes predominant, divine consciousness manifests to restore balance and guide humanity back to the righteous path."
            )
        ]
        
        // For demo purposes, always use the first verse (Chapter 1)
        let sample = sampleVerses[0]
        
        print("📖 Creating sample verse with keywords: \(sample.keywords)")
        print("📖 Creating sample verse with themes: \(sample.themes)")
        
        return Verse(
            id: "daily-\(dayOfYear)",
            chapterIndex: sample.chapter,
            verseIndex: sample.verse,
            devanagariText: sample.devanagari,
            iastText: sample.iast,
            translationEn: sample.translation,
            translationHi: nil, // Sample data doesn't have Hindi translation
            keywords: sample.keywords,
            audioURL: nil,
            commentaryShort: sample.commentary,
            themes: sample.themes
        )
    }
}

#Preview {
    DailyView()
}
