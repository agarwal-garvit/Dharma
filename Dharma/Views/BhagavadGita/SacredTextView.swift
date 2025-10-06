//
//  SacredTextView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct SacredTextView: View {
    @State private var dataManager = DataManager.shared
    @State private var selectedText: SacredTextType = .bhagavadGita
    @State private var selectedChapter: Int = 1
    @State private var selectedVerse: Int = 1
    @State private var isLoading = false
    @State private var showingSearch = false
    @State private var showingTextSelector = false
    
    private var availableTexts: [SacredText] {
        SacredTextType.allCases.map { SacredText(type: $0) }
    }
    
    private var currentText: SacredText {
        SacredText(type: selectedText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Text selector
                textSelector
                
                // Chapter selector
                chapterSelector
                
                // Content area
                if isLoading {
                    loadingView
                } else {
                    contentView
                }
            }
            .navigationTitle(currentText.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingTextSelector = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: currentText.type.icon)
                            Text(currentText.title)
                                .font(.caption)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
        .sheet(isPresented: $showingTextSelector) {
            TextSelectionView(selectedText: $selectedText)
        }
        .sheet(isPresented: $showingSearch) {
            SacredTextSearchView(selectedText: selectedText)
        }
        .onAppear {
            loadChapterContent()
        }
        .onChange(of: selectedText) {
            selectedChapter = 1
            selectedVerse = 1
            loadChapterContent()
        }
    }
    
    private var textSelector: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: currentText.type.icon)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentText.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(currentText.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    showingTextSelector = true
                }) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var chapterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(1...currentText.totalChapters, id: \.self) { chapter in
                    Button(action: {
                        selectedChapter = chapter
                        selectedVerse = 1
                        loadChapterContent()
                    }) {
                        Text("\(chapter)")
                            .font(.headline)
                            .foregroundColor(selectedChapter == chapter ? .white : .orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedChapter == chapter ? Color.orange : Color.orange.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading \(currentText.title) Chapter \(selectedChapter)...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Chapter title
                lessonTitle
                
                // Verses
                versesList
            }
            .padding()
        }
    }
    
    private var lessonTitle: some View {
        VStack(spacing: 8) {
            Text("Chapter \(selectedChapter)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text(getChapterTitle(selectedChapter))
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !currentText.isAvailable {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("Coming Soon")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    private var versesList: some View {
        LazyVStack(spacing: 16) {
            if currentText.isAvailable {
                ForEach(1...getVerseCount(for: selectedChapter), id: \.self) { verse in
                    VerseCard(
                        textType: selectedText,
                        chapter: selectedChapter,
                        verse: verse,
                        isSelected: selectedVerse == verse
                    ) {
                        selectedVerse = verse
                    }
                }
            } else {
                // Show coming soon message for unavailable texts
                VStack(spacing: 16) {
                    Image(systemName: currentText.type.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.orange.opacity(0.5))
                    
                    Text("\(currentText.title) Coming Soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("We're working on bringing you the complete \(currentText.title) with translations, commentaries, and interactive features.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 40)
            }
        }
    }
    
    private func loadChapterContent() {
        isLoading = true
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
        
        // TODO: Implement actual server API call
        // await dataManager.loadChapter(selectedChapter)
    }
    
    private func getChapterTitle(_ chapter: Int) -> String {
        switch selectedText {
        case .bhagavadGita:
            let titles = [
                1: "Arjuna's Despair",
                2: "Sankhya Yoga",
                3: "Karma Yoga",
                4: "Jnana Yoga",
                5: "Karma Sannyasa Yoga",
                6: "Dhyana Yoga",
                7: "Jnana Vijnana Yoga",
                8: "Akshara Brahma Yoga",
                9: "Raja Vidya Yoga",
                10: "Vibhuti Yoga",
                11: "Vishvarupa Darshana Yoga",
                12: "Bhakti Yoga",
                13: "Kshetra Kshetrajna Yoga",
                14: "Gunatraya Vibhaga Yoga",
                15: "Purushottama Yoga",
                16: "Daivasura Sampad Vibhaga Yoga",
                17: "Shraddhatraya Vibhaga Yoga",
                18: "Moksha Sannyasa Yoga"
            ]
            return titles[chapter] ?? "Chapter \(chapter)"
        case .ramayana:
            let titles = [
                1: "Bala Kanda",
                2: "Ayodhya Kanda",
                3: "Aranya Kanda",
                4: "Kishkindha Kanda",
                5: "Sundara Kanda",
                6: "Yuddha Kanda",
                7: "Uttara Kanda"
            ]
            return titles[chapter] ?? "Chapter \(chapter)"
        case .mahabharata:
            return "Parva \(chapter)"
        case .upanishads:
            return "Upanishad \(chapter)"
        case .vedas:
            let titles = [
                1: "Rig Veda",
                2: "Sama Veda",
                3: "Yajur Veda",
                4: "Atharva Veda"
            ]
            return titles[chapter] ?? "Veda \(chapter)"
        }
    }
    
    private func getVerseCount(for chapter: Int) -> Int {
        switch selectedText {
        case .bhagavadGita:
            let counts = [
                1: 47, 2: 72, 3: 43, 4: 42, 5: 29,
                6: 47, 7: 30, 8: 28, 9: 34, 10: 42,
                11: 55, 12: 20, 13: 35, 14: 27, 15: 20,
                16: 24, 17: 28, 18: 78
            ]
            return counts[chapter] ?? 20
        case .ramayana:
            // Approximate verse counts for Ramayana chapters
            let counts = [1: 500, 2: 1000, 3: 800, 4: 600, 5: 700, 6: 1200, 7: 400]
            return counts[chapter] ?? 500
        case .mahabharata:
            return 1000 // Approximate
        case .upanishads:
            return 50 // Approximate
        case .vedas:
            return 1000 // Approximate
        }
    }
}

struct VerseCard: View {
    let textType: SacredTextType
    let chapter: Int
    let verse: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var dataManager = DataManager.shared
    @State private var audioManager = AudioManager.shared
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(chapter).\(verse)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button(action: {
                        // TODO: Play audio for this verse
                        // audioManager.playVerse(verse)
                    }) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                // Verse text (placeholder - will be loaded from server)
                VStack(alignment: .leading, spacing: 8) {
                    if textType == .bhagavadGita {
                        Text("कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।")
                            .font(.title3)
                            .fontWeight(.medium)
                            .lineSpacing(2)
                        
                        Text("karmaṇy-evādhikāras te mā phaleṣu kadācana")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(1)
                        
                        Text("You have a right to action alone, not to its fruits.")
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(1)
                    } else {
                        Text("Content coming soon...")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.1) : Color(.systemBackground))
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TextSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedText: SacredTextType
    
    private var availableTexts: [SacredText] {
        SacredTextType.allCases.map { SacredText(type: $0) }
    }
    
    var body: some View {
        NavigationView {
            List(availableTexts, id: \.id) { text in
                Button(action: {
                    selectedText = text.type
                    dismiss()
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: text.type.icon)
                            .font(.title2)
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(text.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(text.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            HStack {
                                Text("\(text.totalChapters) chapters")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                
                                Text("•")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("\(text.totalVerses) verses")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Spacer()
                        
                        if text.isAvailable {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            VStack(spacing: 2) {
                                Image(systemName: "clock")
                                    .foregroundColor(.orange)
                                Text("Soon")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Sacred Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SacredTextSearchView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedText: SacredTextType
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    
    private var currentText: SacredText {
        SacredText(type: selectedText)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search \(currentText.title)...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            performSearch()
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding()
                
                // Search results
                if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: currentText.type.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("Search \(currentText.title)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Enter keywords, verse references, or themes to find relevant content")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchResults, id: \.self) { result in
                        Text(result)
                    }
                }
            }
            .navigationTitle("Search \(currentText.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func performSearch() {
        // TODO: Implement actual search functionality
        searchResults = ["Search functionality coming soon..."]
    }
}

#Preview {
    SacredTextView()
}
