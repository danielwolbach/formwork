//
//  ScreenStack.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import FormworkKit
import SwiftUI

struct ScreenStack<Content: View>: View {
    private static var margin: CGFloat {
        16
    }

    private static var spacing: CGFloat {
        32
    }

    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: Self.spacing) {
                content()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, Self.margin)
        }
    }
}

#Preview {
    NavigationStack {
        ScreenStack {
            DisplayableHero(displayable: Samples.exercises.first)

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
