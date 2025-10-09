//
//  CachedAsyncImage.swift
//  Dharma
//
//  Created for efficient image loading with caching
//

import SwiftUI

/// A view that loads and caches images from URLs
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @StateObject private var storageManager = StorageManager.shared
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        
        // Check cache first
        if let cachedImage = storageManager.getCachedImage(for: url) {
            loadedImage = cachedImage
            return
        }
        
        // Load from network
        isLoading = true
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    storageManager.cacheImage(image, for: url)
                    loadedImage = image
                    isLoading = false
                }
            }
        } catch {
            print("❌ Failed to load image from \(url): \(error.localizedDescription)")
            isLoading = false
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL?) {
        self.init(
            url: url,
            content: { image in image },
            placeholder: { ProgressView() }
        )
    }
}

extension CachedAsyncImage where Placeholder == Color {
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.init(
            url: url,
            content: content,
            placeholder: { Color.gray.opacity(0.2) }
        )
    }
}

// MARK: - Preview

#Preview {
    CachedAsyncImage(
        url: URL(string: "https://example.com/image.jpg")
    ) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    } placeholder: {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                ProgressView()
            )
    }
    .frame(width: 200, height: 120)
    .cornerRadius(12)
}

