//
//  SummaryRow.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct NavigationRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack {
            IconTile(systemImage: systemImage, color: color, size: .regular)

            VStack(alignment: .leading) {
                Text(title).font(.headline)

                Text(subtitle)
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
