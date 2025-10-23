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
            // Heart with number inside (no timer shown here)
            ZStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(livesManager.currentLives > 0 ? .red : .gray)
                
                Text("\(livesManager.currentLives)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: -1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
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

