//
//  DailyView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 10/22/25.
//

import SwiftUI

struct DailyView: View {
    @State private var dailyVerse: Verse?
    @State private var isLoading = true
    @State private var currentDate = Date()
    @State private var livesManager = LivesManager.shared
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: currentDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                if isLoading {
                    loadingView
                } else if let verse = dailyVerse {
                    // Scripture Card
                    scriptureCard(verse: verse)
                    
                    // Interpretation Section
                    interpretationSection(verse: verse)
                } else {
                    emptyStateView
                }
            }
        }
        .background(ThemeManager.appBackground)
        .onAppear {
            loadDailyVerse()
            
            // Check and regenerate lives
            Task {
                await livesManager.checkAndRegenerateLives()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Date
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Title
            VStack(spacing: 4) {
                Text("Daily Scripture")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Wisdom from the Bhagavad Gita")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.horizontal, 40)
                .padding(.top, 8)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.5))
    }
    
    private func scriptureCard(verse: Verse) -> some View {
        VStack(spacing: 24) {
            // Chapter and Verse Reference
            HStack {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.orange)
                Text("Chapter \(verse.chapterIndex), Verse \(verse.verseIndex)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(20)
            
            // Sanskrit/Devanagari Text
            VStack(spacing: 16) {
                Text("Sanskrit")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text(verse.devanagariText)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.05), Color.yellow.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            
            // IAST Transliteration
            VStack(spacing: 12) {
                Text("Transliteration")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text(verse.iastText)
                    .font(.body)
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // English Translation
            VStack(spacing: 12) {
                Text("Translation")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text(verse.translationEn)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .lineSpacing(4)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    private func interpretationSection(verse: Verse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.blue)
                Text("Interpretation")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Commentary
            if let commentary = verse.commentaryShort, !commentary.isEmpty {
                Text(commentary)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(6)
            } else {
                Text("This verse speaks to the eternal wisdom of dharma and the path of righteousness. Through regular contemplation of these teachings, we develop clarity in our thoughts and actions.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(6)
            }
            
            
            // Reflection Prompt
            reflectionPrompt
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 32)
    }
    
    private var reflectionPrompt: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("Daily Reflection")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }
            
            Text("How can you apply this wisdom to your life today?")
                .font(.body)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.05), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .padding(.top, 8)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading today's wisdom...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No scripture available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Please check back later")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
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
                        self.dailyVerse = dailyVerse.toVerse()
                        self.isLoading = false
                    }
                    return
                }
                
                // If no verse for today, try to get by day of year (cycling through available verses)
                let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: currentDate) ?? 1
                if let dailyVerse = try await databaseService.fetchDailyVerseByDayOfYear(dayOfYear: dayOfYear) {
                    await MainActor.run {
                        self.dailyVerse = dailyVerse.toVerse()
                        self.isLoading = false
                    }
                    return
                }
                
                // If still no verse, try to get the next available verse
                if let dailyVerse = try await databaseService.fetchNextDailyVerse() {
                    await MainActor.run {
                        self.dailyVerse = dailyVerse.toVerse()
                        self.isLoading = false
                    }
                    return
                }
                
                // Fallback to sample verse if no database verses are available
                await MainActor.run {
                    self.dailyVerse = createSampleVerse(dayOfYear: dayOfYear)
                    self.isLoading = false
                }
                
            } catch {
                print("Error loading daily verse from database: \(error)")
                
                // Fallback to sample verse on error
                let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: currentDate) ?? 1
                await MainActor.run {
                    self.dailyVerse = createSampleVerse(dayOfYear: dayOfYear)
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
            keywords: sample.keywords,
            audioURL: nil,
            commentaryShort: sample.commentary,
            themes: sample.themes
        )
    }
}

// Flow Layout for wrapping tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    DailyView()
}

