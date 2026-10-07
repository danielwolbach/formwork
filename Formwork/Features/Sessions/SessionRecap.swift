//
//  SessionRecap.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import Flow
import FormworkKit
import FormworkUI
import SwiftUI

struct SessionRecap: View {
    private let session: Session

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        ContentStack {
            PictogramHeader(
                session.pictogram,
                title: session.title,
                subtitle: session.startDate.formatted(session.wallClockTime(date: .numeric))
            )

            SessionFigureGrid(session)

            VStack(spacing: 0) {
                ForEach(session.orderedEntries) { entry in
                    SessionEntryRow(entry)
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
        
        let label: String
    }

    private let entry: SessionEntry

    @Environment(\.units)
    private var units: Units

    init(_ entry: SessionEntry) {
        self.entry = entry
    }

    var body: some View {
        if let exercise = entry.exercise {
            NavigationLink(value: exercise) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        let details = details

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                PictogramRow(
                    entry.pictogram,
                    title: entry.title,
                    subtitle: entry.target.formatted(.exerciseTarget(units: units)),
                    badge: badge
                )

                if entry.exercise != nil {
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityValue(entry.status.title)

            if !details.isEmpty {
                HFlow {
                    ForEach(details, id: \.pictogram) { detail in
                        Label(detail.text, systemImage: detail.pictogram.image)
                            .monospacedDigit()
                            .labelStyle(.chip(tint: detail.pictogram.color))
                            .accessibilityLabel(detail.label)
                    }
                }
                // From PictogramRow's height
                .padding(.leading, 64 + 8)
            }
        }
        .contentShape(.rect)
    }

    private var badge: Pictogram {
        entry.isBest ? .recordBadge : entry.status.pictogram
    }

    private var details: [Detail] {
        var details: [Detail] = []

        if let resolved = entry.status.resolvedDate, let session = entry.session {
            let time = resolved.formatted(session.wallClockTime())
            let label = entry.status.isCompleted ? String(localized: .recapTimeCompletedLabel(time: time)) : String(localized: .recapTimeSkippedLabel(time: time))
            details.append(Detail(pictogram: .time, text: time, label: label))
        }

        if let duration = entry.duration, entry.status.isCompleted {
            let text = Reading.duration(seconds: duration).formatted(.reading(units: units))
            details.append(Detail(pictogram: .pace, text: text, label: String(localized: .recapDurationLabel(duration: text))))
        }

        if let previous = entry.previous, previous.rank != entry.target.rank {
            let change = entry.target.rank - previous.rank
            let text = Reading(rank: abs(change), of: entry.target.exerciseKind).formatted(.reading(units: units))
            let label = change > 0 ? String(localized: .recapChangeIncreaseLabel(change: text)) : String(localized: .recapChangeDecreaseLabel(change: text))
            details.append(Detail(pictogram: change > 0 ? .increase : .decrease, text: text, label: label))
        }

        return details
    }
}

#Preview {
    NavigationRoot {
        ScrollView {
            SessionRecap(Samples.sessions.first!)
        }
    }
    .sampleData()
}
