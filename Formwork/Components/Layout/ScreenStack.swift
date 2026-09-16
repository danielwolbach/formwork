//
//  ScreenStack.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import FormworkKit
import SwiftUI

struct ScreenStack<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                content()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    NavigationStack {
        ScreenStack {
            DisplayableHero(displayable: Samples.exercises.first!)

            TileGrid {
                StatisticCard(
                    title: .statisticStreakTitle,
                    value: "4 Weeks",
                    pictogram: .streak
                )

                StatisticCard(
                    title: .statisticLastSessionTitle,
                    value: nil,
                    pictogram: .date
                )
            }

            SectionStack(title: Text(.screenCatalogTitle)) {
                RowStack(navigating: Array(Samples.exercises.prefix(4)))
            }
        }
        .navigationTitle(.screenOverviewTitle)
    }
    .sampleData()
}
