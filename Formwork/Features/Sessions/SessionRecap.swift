//
//  SessionRecap.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionRecap: View {
    private let session: Session

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        let summary = session.summary()

        VStack(spacing: 32) {
            DisplayableHeader(session)

            TileGrid {
                MetricCard(summary.duration)

                MetricCard(summary.endTime)

                MetricCard(summary.skipRate)

                MetricCard(summary.medianExerciseDuration)

                MetricCard(summary.completedExercises)

                MetricCard(summary.totalVolume)
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(session.orderedEntries) { entry in
                    SessionEntryRow(entry)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
        }
    }
}

private struct SessionEntryRow: View {
    private struct Detail {
        let pictogram: Pictogram
        let text: String
    }

    private let entry: SessionEntry

    init(_ entry: SessionEntry) {
        self.entry = entry
    }

    var body: some View {
        let details = details

        VStack(alignment: .leading, spacing: 8) {
            DisplayableRow(entry, badge: badge)

            if !details.isEmpty {
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
    }

    private var badge: Pictogram {
        entry.isBest ? .recordBadge : entry.status.pictogram
    }

    private var details: [Detail] {
        var details: [Detail] = []

        if let resolved = entry.status.resolvedDate, let session = entry.session {
            details.append(Detail(pictogram: .time, text: resolved.formatted(session.wallClockTime())))
        }

        if let duration = entry.duration, entry.status.isCompleted {
            details.append(Detail(pictogram: .pace, text: duration.formatted(DurationFormat())))
        }

        if let previous = entry.previous, previous.rank != entry.target.rank {
            let change = entry.target.rank - previous.rank
            details.append(Detail(pictogram: change > 0 ? .increase : .decrease, text: TargetFormat(kind: entry.target.exerciseKind).format(abs(change))))
        }

        return details
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            SessionRecap(Samples.sessions.first!)
        }
    }
    .sampleData()
}
