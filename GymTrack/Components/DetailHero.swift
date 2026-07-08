//
//  DetailHero.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct DetailHero: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 32) {
            IconTile(systemImage: systemImage, color: color, size: .large)
            
            VStack {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    DetailHero(title: "Title", subtitle: "Subtitle", systemImage: "sparkles", color: .accentColor)
}
