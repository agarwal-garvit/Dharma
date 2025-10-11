//
//  RichContentView.swift
//  Dharma
//
//  A view that displays rich content with embedded images
//

import SwiftUI

struct RichContentView: View {
    let content: String
    let font: Font
    let lineSpacing: CGFloat
    let foregroundColor: Color
    
    @StateObject private var storageManager = StorageManager.shared
    
    private var parsedContent: [ContentElement] {
        ContentParser.parseContent(content)
    }
    
    init(
        content: String,
        font: Font = .title3,
        lineSpacing: CGFloat = 4,
        foregroundColor: Color = .primary
    ) {
        self.content = content
        self.font = font
        self.lineSpacing = lineSpacing
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(parsedContent, id: \.id) { element in
                switch element.type {
                case .text:
                    Text(element.content)
                        .font(font)
                        .fontWeight(.medium)
                        .lineSpacing(lineSpacing)
                        .foregroundColor(foregroundColor)
                        .multilineTextAlignment(.leading)
                
                case .image(let path, let altText):
                    ChapterImageView(
                        imagePath: path,
                        altText: altText
                    )
                }
            }
        }
    }
}

struct ChapterImageView: View {
    let imagePath: String
    let altText: String
    
    @StateObject private var storageManager = StorageManager.shared
    
    private var imageURL: URL? {
        storageManager.getChapterImageURL(filePath: imagePath)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            CachedAsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading image...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            
            // Caption removed - images display without text below
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            RichContentView(
                content: """
                This is where Krishna's teaching truly begins. Seeing Arjuna paralyzed by grief, Krishna initially challenges him, calling his sorrow unworthy of a warrior and contrary to the path of honor.
                
                [IMAGE:chapter-images/Ch2Img1.png|Ch2Img1]
                
                Krishna teaches the distinction between the eternal soul (atman) and the temporary body. The soul is immortal, indestructible, unchanging—it cannot be cut by weapons, burned by fire, or wetted by water.
                
                [IMAGE:chapter-images/Ch2Img2.png|Ch2Img2]
                
                The chapter ends with a warning: attachment to sense objects leads to desire, desire to anger, anger to delusion, delusion to loss of memory, and ultimately to destruction.
                """
            )
        }
        .padding()
    }
}