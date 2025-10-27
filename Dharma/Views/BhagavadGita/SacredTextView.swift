//
//  SacredTextView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct SacredTextView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Coming Soon Icon
                    Image(systemName: "scroll.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
        VStack(spacing: 16) {
                        Text("Sacred Texts")
                            .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                        Text("Complete access to sacred texts coming soon")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                    
                    VStack(spacing: 12) {
                        Text("Including:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            Text("• Bhagavad Gita")
                            Text("• Mahabharata")
                            Text("• Ramayana")
                            Text("• Upanishads")
                            Text("• Vedas")
                        }
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Texts")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SacredTextView()
}