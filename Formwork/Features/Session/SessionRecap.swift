//
//  SessionRecap.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct SessionRecap: View {
    let session: Session

    var body: some View {
        let summary = session.summary()

        VStack(spacing: 32) {
            PictogramHeader(session)

            TileGrid(columns: 2) {
                ValueCard(summary.duration)
                ValueCard(summary.endTime)
                ValueCard(summary.skipRate)
                ValueCard(summary.medianExerciseDuration)
                ValueCard(summary.completedExercises)
                ValueCard(summary.totalVolume)
            }
            .padding(.horizontal)

            LazyVStack(spacing: 0) {
                ForEach(session.orderedEntries) { entry in
                    SessionEntryRow(entry: entry, badge: badge(for: entry), details: details(for: entry))
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
        }
    }

    private func badge(for entry: SessionEntry) -> Pictogram {
        entry.isBest ? .recordBadge : entry.status.pictogram
    }

    private func details(for entry: SessionEntry) -> [(pictogram: Pictogram, text: String)] {
        var details: [(pictogram: Pictogram, text: String)] = []

        if let resolved = entry.status.resolvedDate {
            details.append((.time, resolved.formatted(session.wallClockTime())))
        }

        if let duration = entry.duration {
            if entry.status.isCompleted {
                details.append((.pace, Duration.seconds(duration).formatted(.exerciseDuration)))
            }
        }

        if let previous = entry.previous, previous.rank != entry.target.rank {
            let change = entry.target.rank - previous.rank
            details.append((change > 0 ? .increase : .decrease, entry.target.formattedRank(abs(change))))
        }

        return details
    }
}

private struct SessionEntryRow: View {
    let entry: SessionEntry

    let badge: Pictogram

    let details: [(pictogram: Pictogram, text: String)]

    @State
    private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    PictogramRow(entry, badge: badge)

                    if !details.isEmpty {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.tertiary)
                            .scaleEffect(y: isExpanded ? -1 : 1)
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded, !details.isEmpty {
                FlowLayout(alignment: .leading) {
                    ForEach(details, id: \.pictogram) { detail in
                        Label(detail.text, systemImage: detail.pictogram.image)
                            .monospacedDigit()
                            .labelStyle(.chip(tint: detail.pictogram.color))
                    }
                }
                .padding(.leading, 64 + 8)
            }
        }
        .sensoryFeedback(.selection, trigger: isExpanded)
    }
}

#Preview {
    let sessions = (try? Samples.container.mainContext.fetch(Session.finishedDescriptor)) ?? []

    NavigationStack {
        if let session = sessions.first {
            ScrollView {
                SessionRecap(session: session)
            }
        }
    }
    .sampleData()
}
