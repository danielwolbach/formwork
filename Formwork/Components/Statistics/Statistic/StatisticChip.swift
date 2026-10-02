//
//  StatisticChip.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct StatisticChip: View {
    private let kind: StatisticKind

    private let history: History

    @Environment(\.units)
    private var units: Units

    init(_ kind: StatisticKind, of history: History) {
        self.kind = kind
        self.history = history
    }

    var body: some View {
        let pictogram = kind.statistic.pictogram

        Label {
            Text(verbatim: text)

            if let subtitle = history.subject.title {
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: pictogram.image)
        }
        .labelStyle(.chip(tint: pictogram.color))
    }

    /// A chip has no room for a chart, so it names the statistic instead, without working the chart out.
    private var text: String {
        guard !kind.isChart, case let .reading(reading, _) = kind.summary(of: history) else {
            return kind.statistic.title
        }

        return reading?.formatted(.reading(units: units)) ?? "—"
    }
}

#Preview {
    let history = History(.all, among: Samples.sessions)

    VStack {
        StatisticChip(.weekStreak, of: history)

        StatisticChip(.activeDays, of: history)
    }
    .padding()
}
