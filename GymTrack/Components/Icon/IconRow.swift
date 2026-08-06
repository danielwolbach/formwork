//
//  IconRow.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct IconRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            IconBadge(icon: icon, color: color)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    IconRow(icon: "sparkles", color: .accentColor, title: "Title", subtitle: "Subtitle")
        .padding(.horizontal)
}
