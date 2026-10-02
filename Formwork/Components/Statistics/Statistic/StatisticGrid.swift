//
//  StatisticGrid.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct StatisticGrid: View {
    private let history: History

    private let includesCharts: Bool

    @State
    private var selection: StatisticKind? = nil

    init(_ history: History, includesCharts: Bool = true) {
        self.history = history
        self.includesCharts = includesCharts
    }

    var body: some View {
        TileGrid {
            ForEach(history.subject.statistics.filter { includesCharts || !$0.isChart }, id: \.self) { kind in
                StatisticCard(kind, of: history) {
                    // A tap above an open sheet also reaches the cards behind it, so it may only close the sheet.
                    guard selection == nil else {
                        return
                    }

                    selection = kind
                }
            }
        }
        .sheet(item: $selection) { kind in
            NavigationStack {
                StatisticSheet(kind, of: history)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ContentStack {
                StatisticGrid(History(.exercise(Samples.exercises[2]), among: Samples.sessions))
            }
        }
    }
    .sampleData()
}
