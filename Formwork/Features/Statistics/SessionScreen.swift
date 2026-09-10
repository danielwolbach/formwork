//
//  SessionScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct SessionScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var deleteAlert: Bool = false

    let session: Session

    var body: some View {
        ScreenStack {
            DisplayableHero(displayable: session)

            TileGrid {
                StatisticCard(
                    title: .statisticDurationTitle,
                    value: session.duration.map {
                        Duration.seconds($0).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
                    },
                    pictogram: .duration
                )

                StatisticCard(
                    title: .statisticFinishedAtTitle,
                    value: session.completion?.formatted(date: .omitted, time: .shortened),
                    pictogram: .time
                )

                StatisticCard(
                    title: .sessionStatusCompletedTitle,
                    value: session.completedCount.formatted(),
                    pictogram: .completed
                )

                StatisticCard(
                    title: .sessionStatusSkippedTitle,
                    value: session.skippedCount.formatted(),
                    pictogram: .skipped
                )
            }

            RowStack(items: session.orderedEntries) { entry in
                HStack {
                    DisplayableRow(displayable: entry)

                    if let resolved = entry.status.resolved {
                        Text(Duration.seconds(resolved.timeIntervalSince(session.started))
                            .formatted(.time(pattern: .hourMinute)))
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .toolbar {
            Menu(.more) {
                Button(.delete) {
                    deleteAlert = true
                }
            }
        }
        .alert(.alertSessionDeleteTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertSessionDeleteMessage)
        }
    }

    private func delete() {
        modelContext.delete(session)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SessionScreen(session: Samples.finishedSessions.first!)
    }
    .sampleData()
}
