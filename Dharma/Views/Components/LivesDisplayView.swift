//
//  LivesDisplayView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 10/22/25.
//

import SwiftUI

struct LivesDisplayView: View {
    @ObservedObject var livesManager = LivesManager.shared
    @State private var showLivesModal = false
    
    var body: some View {
        Button(action: {
            showLivesModal = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(livesManager.currentLives > 0 ? .red : .gray)
                
                Text("\(livesManager.currentLives)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showLivesModal) {
            LivesModalView()
        }
    }
}

#Preview {
    LivesDisplayView()
}