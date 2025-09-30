//
//  SearchView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct SearchView: View {
    @State private var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var searchResults: [Verse] = []
    @State private var isSearching = false
    @State private var selectedVerse: Verse?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Search results
                if isSearching {
                    searchResultsView
                } else {
                    searchSuggestionsView
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedVerse) { verse in
            VerseDetailView(verse: verse)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search verses, keywords, or themes...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    performSearch()
                }
                .onChange(of: searchText) { _, newValue in
                    if newValue.isEmpty {
                        searchResults = []
                        isSearching = false
                    } else if newValue.count >= 2 {
                        performSearch()
                    }
                }
            
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                    searchResults = []
                    isSearching = false
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try searching for different keywords or verse references like '2.47'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ForEach(searchResults) { verse in
                        SearchResultRow(verse: verse) {
                            selectedVerse = verse
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var searchSuggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Quick search suggestions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Search")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        QuickSearchButton(title: "Chapter 2", subtitle: "Sankhya Yoga", searchTerm: "2") {
                            searchText = "2"
                            performSearch()
                        }
                        
                        QuickSearchButton(title: "Chapter 12", subtitle: "Bhakti Yoga", searchTerm: "12") {
                            searchText = "12"
                            performSearch()
                        }
                        
                        QuickSearchButton(title: "Karma", subtitle: "Action & Duty", searchTerm: "karma") {
                            searchText = "karma"
                            performSearch()
                        }
                        
                        QuickSearchButton(title: "Dharma", subtitle: "Righteousness", searchTerm: "dharma") {
                            searchText = "dharma"
                            performSearch()
                        }
                    }
                }
                
                // Popular themes
                VStack(alignment: .leading, spacing: 16) {
                    Text("Popular Themes")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(["detachment", "equanimity", "devotion", "wisdom"], id: \.self) { theme in
                            QuickSearchButton(title: theme.capitalized, subtitle: "Theme", searchTerm: theme) {
                                searchText = theme
                                performSearch()
                            }
                        }
                    }
                }
                
                // Recent searches (placeholder)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Searches")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        Text("No recent searches")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        searchResults = dataManager.searchVerses(query: searchText)
    }
}

struct QuickSearchButton: View {
    let title: String
    let subtitle: String
    let searchTerm: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchResultRow: View {
    let verse: Verse
    let onTap: () -> Void
    @State private var dataManager = DataManager.shared
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Verse \(verse.reference)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                // Show verse text based on user preference
                if dataManager.userPreferences.scriptDisplay == .devanagari || dataManager.userPreferences.scriptDisplay == .both {
                    Text(verse.devanagariText)
                        .font(.title3)
                        .fontWeight(.medium)
                        .lineSpacing(2)
                }
                
                if dataManager.userPreferences.scriptDisplay == .iast || dataManager.userPreferences.scriptDisplay == .both {
                    Text(verse.iastText)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(1)
                }
                
                Text(verse.translationEn)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(1)
                    .lineLimit(3)
                
                // Keywords
                if !verse.keywords.isEmpty {
                    HStack {
                        ForEach(verse.keywords.prefix(3), id: \.self) { keyword in
                            Text(keyword)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.orange.opacity(0.1))
                                )
                                .foregroundColor(.orange)
                        }
                        
                        if verse.keywords.count > 3 {
                            Text("+\(verse.keywords.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct VerseDetailView: View {
    let verse: Verse
    @Environment(\.dismiss) private var dismiss
    @State private var dataManager = DataManager.shared
    @State private var audioManager = AudioManager.shared
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Verse header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chapter \(verse.chapterIndex), Verse \(verse.verseIndex)")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        if let chapter = dataManager.chapters.first(where: { $0.index == verse.chapterIndex }) {
                            Text(chapter.titleEn)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    
                    // Verse text
                    VStack(alignment: .leading, spacing: 16) {
                        if dataManager.userPreferences.scriptDisplay == .devanagari || dataManager.userPreferences.scriptDisplay == .both {
                            Text(verse.devanagariText)
                                .font(.title2)
                                .fontWeight(.medium)
                                .lineSpacing(4)
                        }
                        
                        if dataManager.userPreferences.scriptDisplay == .iast || dataManager.userPreferences.scriptDisplay == .both {
                            Text(verse.iastText)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                        
                        Text(verse.translationEn)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(2)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Commentary
                    if let commentary = verse.commentaryShort {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Commentary")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(commentary)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                    
                    // Keywords and themes
                    VStack(alignment: .leading, spacing: 12) {
                        if !verse.keywords.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Keywords")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                    ForEach(verse.keywords, id: \.self) { keyword in
                                        Text(keyword)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.blue.opacity(0.1))
                                            )
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        
                        if !verse.themes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Themes")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                    ForEach(verse.themes, id: \.self) { theme in
                                        Text(theme)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.green.opacity(0.1))
                                            )
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            audioManager.playVerse(verse)
                        }) {
                            HStack {
                                Image(systemName: audioManager.isPlaying && audioManager.currentVerse?.id == verse.id ? "pause.circle.fill" : "play.circle.fill")
                                Text("Play Audio")
                            }
                            .foregroundColor(.orange)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Spacer()
                        
                        Button("Add to Review") {
                            let reviewItem = ReviewItem(
                                id: "verse_\(verse.id)_\(Date().timeIntervalSince1970)",
                                kind: .verse,
                                payloadRef: verse.id
                            )
                            dataManager.reviewItems.append(reviewItem)
                            dataManager.saveUserData()
                            
                            HapticManager.shared.buttonTap()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Share") {
                            showingShareSheet = true
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Verse \(verse.reference)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [verse.translationEn])
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SearchView()
}
