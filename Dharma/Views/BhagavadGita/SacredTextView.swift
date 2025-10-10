//
//  SacredTextView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct SacredTextView: View {
    @State private var dataManager = DataManager.shared
    @State private var selectedChapter: Int = 1
    @State private var isLoading = false
    
    // Fixed to Bhagavad Gita for now
    private let selectedText: SacredTextType = .bhagavadGita
    
    private var currentText: SacredText {
        SacredText(type: selectedText)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Chapter selector
                    chapterSelector
                    
                    // Content area - book-like page
                    if isLoading {
                        loadingView
                    } else {
                        bookPageView
                    }
                }
            }
            .navigationTitle("Bhagavad Gita")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadChapterContent()
        }
        .onChange(of: selectedChapter) {
            loadChapterContent()
        }
    }
    
    private var chapterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(1...currentText.totalChapters, id: \.self) { chapter in
                    Button(action: {
                        selectedChapter = chapter
                    }) {
                        Text("Ch. \(chapter)")
                            .font(.subheadline)
                            .fontWeight(selectedChapter == chapter ? .semibold : .regular)
                            .foregroundColor(selectedChapter == chapter ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selectedChapter == chapter ? Color.orange : Color(.systemGray5))
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
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
    
    private var bookPageView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Chapter title
                VStack(alignment: .center, spacing: 8) {
                    Text("Chapter \(selectedChapter)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(getChapterTitle(selectedChapter))
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
                
                // Verses displayed as continuous text
                ForEach(1...getVerseCount(for: selectedChapter), id: \.self) { verse in
                    VStack(alignment: .leading, spacing: 12) {
                        // Verse number
                        Text("\(selectedChapter).\(verse)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        // Sanskrit text
                        Text("कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        // Transliteration
                        Text("karmaṇy-evādhikāras te mā phaleṣu kadācana")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                            .lineSpacing(2)
                        
                        // Translation
                        Text("You have a right to action alone, not to its fruits.")
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(2)
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .padding(16)
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
        let counts = [
            1: 47, 2: 72, 3: 43, 4: 42, 5: 29,
            6: 47, 7: 30, 8: 28, 9: 34, 10: 42,
            11: 55, 12: 20, 13: 35, 14: 27, 15: 20,
            16: 24, 17: 28, 18: 78
        ]
        return counts[chapter] ?? 20
    }
}

#Preview {
    SacredTextView()
}
