//
//  SessionStatistics.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct SessionStatistics: View {
    let session: Session

    var body: some View {
        StatisticsStack {
            StatisticsRowStack {
                MetricCard(
                    value: session.duration?.formatted(.time(pattern: .hourMinute(padHourToLength: 1))) ?? "–",
                    title: .statsDuration,
                    icon: "clock",
                    tint: .purple
                )

                MetricCard(
                    value: session.completionRate?.formatted(.percent.precision(.fractionLength(0))) ?? "–",
                    title: .statsCompletionRate,
                    icon: "checkmark.seal",
                    tint: .blue
                )
            }

            StatisticsRowStack {
                MetricCard(
                    value: session.completedEntryCount.formatted(),
                    title: .statsCompletedExecutions,
                    icon: "checkmark.circle",
                    tint: .green
                )

                MetricCard(
                    value: session.skippedEntryCount.formatted(),
                    title: .statsSkippedExecutions,
                    icon: "forward.end",
                    tint: .orange
                )
            }

            StatisticsCard(title: .statsSessionEntries, icon: "list.bullet", tint: .blue) {
                VStack(spacing: 0) {
                    ForEach(session.orderedEntries.indices, id: \.self) { index in
                        SessionStatisticsEntryRow(entry: session.orderedEntries[index])

                        if index < session.orderedEntries.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

private struct SessionStatisticsEntryRow: View {
    let entry: SessionEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.status.icon)
                .foregroundStyle(entry.status.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.exercise.title)
                Text(entry.target.title)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .font(.subheadline)
        .padding(.vertical, 10)
    }
}
