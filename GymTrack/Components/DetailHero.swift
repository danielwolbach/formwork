//
//  DetailHero.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct DetailHero: View {
    let title: String
    let subtitle: Text?
    let systemImage: String
    let color: Color

    init(title: String, subtitle: String? = nil, systemImage: String, color: Color) {
        self.title = title
        self.subtitle = subtitle.map(Text.init)
        self.systemImage = systemImage
        self.color = color
    }

    init(title: String, subtitle: Text, systemImage: String, color: Color) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.color = color
    }

    var body: some View {
        VStack(spacing: 32) {
            IconTile(systemImage: systemImage, color: color, size: .large)

            VStack {
                Text(title)
                    .font(.headline)

                if let subtitle {
                    subtitle
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DetailHero(title: "Title", subtitle: "Subtitle", systemImage: "sparkles", color: .accentColor)
}
