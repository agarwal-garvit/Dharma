//
//  ContentParser.swift
//  Dharma
//
//  Content parsing utility for handling rich text with embedded images
//

import Foundation
import SwiftUI

struct ContentElement {
    let id = UUID()
    let type: ContentElementType
    let content: String
}

enum ContentElementType {
    case text
    case image(path: String, altText: String)
}

class ContentParser {
    
    /// Parse content string that may contain image references
    /// Format: [IMAGE:chapter-images/Ch2Img1.png|Ch2Img1]
    static func parseContent(_ content: String) -> [ContentElement] {
        var elements: [ContentElement] = []
        let imagePattern = #"\[IMAGE:([^|]+)\|([^\]]+)\]"#
        
        do {
            let regex = try NSRegularExpression(pattern: imagePattern, options: [])
            let range = NSRange(content.startIndex..., in: content)
            
            var lastEnd = content.startIndex
            
            regex.enumerateMatches(in: content, options: [], range: range) { match, _, _ in
                guard let match = match else { return }
                
                // Add text before image
                let imageRange = Range(match.range, in: content)!
                if lastEnd < imageRange.lowerBound {
                    let textContent = String(content[lastEnd..<imageRange.lowerBound])
                    if !textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        elements.append(ContentElement(
                            type: .text,
                            content: textContent
                        ))
                    }
                }
                
                // Extract image path and alt text
                if match.numberOfRanges >= 3 {
                    let pathRange = Range(match.range(at: 1), in: content)!
                    let altTextRange = Range(match.range(at: 2), in: content)!
                    
                    let imagePath = String(content[pathRange])
                    let altText = String(content[altTextRange])
                    
                    print("📸 ContentParser: Found image - path: '\(imagePath)', alt: '\(altText)'")
                    
                    elements.append(ContentElement(
                        type: .image(path: imagePath, altText: altText),
                        content: imagePath
                    ))
                }
                
                lastEnd = imageRange.upperBound
            }
            
            // Add remaining text
            if lastEnd < content.endIndex {
                let remainingText = String(content[lastEnd...])
                if !remainingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    elements.append(ContentElement(
                        type: .text,
                        content: remainingText
                    ))
                }
            }
            
        } catch {
            print("❌ Error parsing content: \(error)")
            // Fallback: return content as single text element
            elements.append(ContentElement(type: .text, content: content))
        }
        
        // If no elements were found, return the original content as text
        if elements.isEmpty {
            elements.append(ContentElement(type: .text, content: content))
        }
        
        return elements
    }
    
    /// Extract image metadata from lesson content JSON
    static func extractImageMetadata(from contentJSON: String) -> [ImageMetadata] {
        guard let data = contentJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let imagesArray = json["images"] as? [[String: Any]] else {
            return []
        }
        
        return imagesArray.compactMap { imageDict in
            guard let name = imageDict["name"] as? String,
                  let path = imageDict["path"] as? String else {
                return nil
            }
            
            return ImageMetadata(
                name: name,
                path: path,
                addedAt: imageDict["added_at"] as? String
            )
        }
    }
    
    /// Parse lesson summary content from JSON structure
    /// Expected format: {"images": [...], "content": "text with [IMAGE:path|altText]"}
    static func parseLessonSummary(from contentJSON: [String: Any]) -> String {
        // If there's a "content" key, use that
        if let content = contentJSON["content"] as? String {
            return content
        }
        
        // Otherwise, if the whole JSON is a string, use that
        if contentJSON.count == 1, let singleValue = contentJSON.values.first as? String {
            return singleValue
        }
        
        return "No summary content available for this chapter."
    }
    
    /// Parse lesson summary content from JSON string
    static func parseLessonSummary(from contentJSONString: String) -> String {
        guard let data = contentJSONString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            // If it's not JSON, treat as plain text
            return contentJSONString
        }
        return parseLessonSummary(from: json)
    }
}

struct ImageMetadata {
    let name: String
    let path: String
    let addedAt: String?
}