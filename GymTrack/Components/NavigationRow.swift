//
//  NavigationRow.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct NavigationRow: View {
    let title: String
    let subtitle: Text
    let systemImage: String
    let color: Color

    init(title: String, subtitle: String, systemImage: String, color: Color) {
        self.title = title
        self.subtitle = Text(subtitle)
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
        HStack {
            IconTile(systemImage: systemImage, color: color, size: .regular)

            VStack(alignment: .leading) {
                Text(title).font(.headline)

                subtitle
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(8)
        .contentShape(.rect)
    }
}

#Preview {
    NavigationStack {
        NavigationRow(title: "Title", subtitle: "Subtitle", systemImage: "sparkles", color: .accentColor)
            .padding()
    }
}
