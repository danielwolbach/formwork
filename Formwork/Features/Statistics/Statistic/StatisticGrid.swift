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

    @State
    private var selection: Statistic? = nil

    init(_ history: History) {
        self.history = history
    }

    var body: some View {
        TileGrid {
            ForEach(history.subject.statistics.filter { $0.isShown(in: history, isHealthConnected: Health.shared.status == .connected) }) { statistic in
                StatisticCard(statistic, of: history) {
                    // A tap above an open sheet also reaches the cards behind it, so it may only close the sheet.
                    guard selection == nil else {
                        return
                    }

                    selection = statistic
                }
            }
        }
        .sheet(item: $selection) { statistic in
            NavigationRoot {
                StatisticSheet(statistic, of: history)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    NavigationRoot {
        ScrollView {
            ContentStack {
                StatisticGrid(History(.exercise(Samples.exercises[2]), among: Samples.sessions))
            }
        }
    }
    .sampleData()
}
