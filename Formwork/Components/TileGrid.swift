//
//  TileGrid.swift
//  Formwork
//
//  Created by Daniel Wolbach on 09.09.26.
//

import FormworkKit
import SwiftUI

struct TileGrid<Content: View>: View {
    var columns: Int = 2
    var spacing: CGFloat = 8

    @ViewBuilder let content: () -> Content

    var body: some View {
        LazyVGrid(columns: GridItem.ntile(n: columns, spacing: spacing), spacing: spacing) {
            content()
        }
    }
}

#Preview("Cards") {
    TileGrid {
        StatisticCard(
            title: .statisticStreakTitle,
            value: "4 Weeks",
            pictogram: Pictogram(icon: "flame", tint: .orange)
        )

        StatisticCard(
            title: .statisticLastSessionTitle,
            value: nil,
            pictogram: Pictogram(icon: "calendar", tint: .indigo)
        )
    }
    .padding()
}

#Preview("Swatches") {
    TileGrid(columns: 6) {
        ForEach(Pictogram.Tint.allCases) { tint in
            Circle()
                .fill(tint.color)
                .frame(height: 40)
        }
    }
    .padding()
}
