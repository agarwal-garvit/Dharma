//
//  BhagavadGitaView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct BhagavadGitaView: View {
    @State private var dataManager = DataManager.shared
    @State private var selectedChapter: Int = 1
    @State private var selectedVerse: Int = 1
    @State private var isLoading = false
    @State private var showingSearch = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chapter selector
                chapterSelector
                
                // Content area
                if isLoading {
                    loadingView
                } else {
                    contentView
                }
            }
            .navigationTitle("Bhagavad Gita")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            GitaSearchView()
        }
        .onAppear {
            loadChapterContent()
        }
    }
    
    private var chapterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(1...18, id: \.self) { chapter in
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
            
            Text("Loading Chapter \(selectedChapter)...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Chapter title
                chapterTitle
                
                // Verses
                versesList
            }
            .padding()
        }
    }
    
    private var chapterTitle: some View {
        VStack(spacing: 8) {
            Text("Chapter \(selectedChapter)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text(getChapterTitle(selectedChapter))
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    private var versesList: some View {
        LazyVStack(spacing: 16) {
            ForEach(1...getVerseCount(for: selectedChapter), id: \.self) { verse in
                VerseCard(
                    chapter: selectedChapter,
                    verse: verse,
                    isSelected: selectedVerse == verse
                ) {
                    selectedVerse = verse
                }
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
    }
    
    private func getVerseCount(for chapter: Int) -> Int {
        // TODO: Get actual verse count from server
        // For now, return approximate counts
        let counts = [
            1: 47, 2: 72, 3: 43, 4: 42, 5: 29,
            6: 47, 7: 30, 8: 28, 9: 34, 10: 42,
            11: 55, 12: 20, 13: 35, 14: 27, 15: 20,
            16: 24, 17: 28, 18: 78
        ]
        return counts[chapter] ?? 20
    }
}

struct VerseCard: View {
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

struct GitaSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search verses, keywords...", text: $searchText)
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
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("Search the Bhagavad Gita")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Enter keywords, verse references, or themes to find relevant verses")
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
            .navigationTitle("Search Gita")
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
    BhagavadGitaView()
}
