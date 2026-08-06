//
//  IconHero.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct IconHero: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 32) {
            IconBadge(icon: icon, color: color, size: 256)

            VStack {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    IconHero(icon: "sparkles", color: .accentColor, title: "Title", subtitle: "Subtitle")
}
