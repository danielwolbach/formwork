//
//  StatisticCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct StatisticCard: View {
    let title: LocalizedStringResource
    let value: String?
    let pictogram: Pictogram

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Spacer(minLength: 0)

            Text(title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)

            Text(verbatim: value ?? "—")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(alignment: .topTrailing) {
            Image(systemName: pictogram.icon)
                .font(.system(size: 96))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(pictogram.color)
                .opacity(0.35)
                .offset(x: 24, y: -32)
        }
        .aspectRatio(1.8, contentMode: .fit)
        .cardFill(tint: pictogram.color)
        .cardSurface()
    }
}

private struct StatisticCardGallery: View {
    var body: some View {
        TileGrid {
            StatisticCard(
                title: .statisticStreakTitle,
                value: "23 Weeks",
                pictogram: .streak
            )
            StatisticCard(
                title: .statisticLastSessionTitle,
                value: "2 Days Ago",
                pictogram: .date
            )
            StatisticCard(
                title: .statisticStreakTitle,
                value: "0 Weeks",
                pictogram: .streak
            )
            StatisticCard(
                title: .statisticLastSessionTitle,
                value: nil,
                pictogram: .date
            )
            StatisticCard(
                title: .statisticStreakTitle,
                value: "127 Wochen",
                pictogram: .streak
            )
            StatisticCard(
                title: .statisticLastSessionTitle,
                value: "Vorgestern Abend",
                pictogram: .date
            )
        }
        .padding()
    }
}

#Preview {
    StatisticCardGallery()
}
