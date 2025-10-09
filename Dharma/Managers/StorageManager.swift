//
//  StorageManager.swift
//  Dharma
//
//  Created for managing Supabase Storage and image caching
//

import Foundation
import SwiftUI
import Supabase
import Combine

@MainActor
class StorageManager: ObservableObject {
    static let shared = StorageManager()
    
    private let supabase: SupabaseClient
    private let bucketName = "lesson-images"
    
    // In-memory cache for images
    private var imageCache = NSCache<NSString, UIImage>()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        self.supabase = SupabaseClient(
            supabaseURL: Config.supabaseURLObject,
            supabaseKey: Config.supabaseKey
        )
        
        // Configure cache
        imageCache.countLimit = 50 // Maximum 50 images in memory
        imageCache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
        
        print("🖼️ StorageManager initialized")
    }
    
    // MARK: - Public URL Generation
    
    /// Get the public URL for a lesson image
    func getLessonImageURL(fileName: String) -> URL? {
        // Supabase Storage public URL format:
        // https://[PROJECT_ID].supabase.co/storage/v1/object/public/[BUCKET]/[FILE_PATH]
        let urlString = "\(Config.supabaseURL)/storage/v1/object/public/\(bucketName)/\(fileName)"
        return URL(string: urlString)
    }
    
    /// Generate URL for a specific lesson
    func getLessonImageURL(lessonId: UUID) -> URL? {
        return getLessonImageURL(fileName: "lesson_\(lessonId.uuidString).jpg")
    }
    
    /// Generate URL for a lesson by order index
    func getLessonImageURL(orderIdx: Int) -> URL? {
        return getLessonImageURL(fileName: "lesson_\(orderIdx).jpg")
    }
    
    // MARK: - Image Upload (for admin/content management)
    
    /// Upload an image to Supabase Storage
    func uploadLessonImage(image: UIImage, fileName: String) async throws -> String {
        isLoading = true
        errorMessage = nil
        
        do {
            // Convert image to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw StorageError.imageConversionFailed
            }
            
            // Upload to Supabase Storage
            // The upload method expects Data directly
            _ = try await supabase.storage
                .from(bucketName)
                .upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(
                        cacheControl: "3600",
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )
            
            let publicURL = getLessonImageURL(fileName: fileName)
            
            isLoading = false
            print("✅ Image uploaded successfully: \(fileName)")
            return publicURL?.absoluteString ?? ""
        } catch {
            isLoading = false
            errorMessage = "Failed to upload image: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Image Caching
    
    /// Get image from cache
    func getCachedImage(for url: URL) -> UIImage? {
        return imageCache.object(forKey: url.absoluteString as NSString)
    }
    
    /// Cache an image
    func cacheImage(_ image: UIImage, for url: URL) {
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale)
        imageCache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }
    
    /// Clear image cache
    func clearCache() {
        imageCache.removeAllObjects()
        print("🗑️ Image cache cleared")
    }
    
    // MARK: - Batch Operations
    
    /// Update lesson with image URL in database
    func updateLessonImage(lessonId: UUID, imageUrl: String) async throws {
        do {
            try await supabase.database
                .from("lessons")
                .update(["image_url": imageUrl])
                .eq("id", value: lessonId)
                .execute()
            
            print("✅ Lesson \(lessonId) updated with image URL")
        } catch {
            errorMessage = "Failed to update lesson image URL: \(error.localizedDescription)"
            throw error
        }
    }
}

// MARK: - Error Types

enum StorageError: LocalizedError {
    case imageConversionFailed
    case uploadFailed
    case downloadFailed
    case bucketNotFound
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to data"
        case .uploadFailed:
            return "Failed to upload image to storage"
        case .downloadFailed:
            return "Failed to download image from storage"
        case .bucketNotFound:
            return "Storage bucket not found"
        }
    }
}

