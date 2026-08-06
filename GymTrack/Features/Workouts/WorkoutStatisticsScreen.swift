//
//  WorkoutStatisticsScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct WorkoutStatisticsScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Bindable var workout: Workout

    var body: some View {
        ScrollView {
            ScreenStack {
                ScreenSection {
                    StatisticsStack {
                        StatisticsRowStack {
                            MetricCard(
                                value: workout.totalCompletionCount.formatted(),
                                title: .statsTotalCompletions,
                                icon: "checkmark.circle",
                                tint: .green
                            )

                            MetricCard(
                                value: lastCompletedText,
                                title: .statsLastCompleted,
                                icon: "calendar",
                                tint: .blue
                            )
                        }

                        StatisticsRowStack {
                            MetricCard(
                                value: workout.typicalDuration?
                                    .formatted(.time(pattern: .hourMinute(padHourToLength: 1))) ?? "–",
                                title: .statsTypicalDuration,
                                icon: "clock",
                                tint: .purple
                            )

                            MetricCard(
                                value: workout.completionRate?
                                    .formatted(.percent.precision(.fractionLength(0))) ?? "–",
                                title: .statsCompletionRate,
                                icon: "checkmark.seal",
                                tint: .orange
                            )
                        }

                        if !workout.disciplineDistribution.isEmpty {
                            DisciplineDistributionChart(data: workout.disciplineDistribution)
                        }

                        if !workout.recentDurationTrend.isEmpty {
                            WorkoutDurationChart(data: workout.recentDurationTrend, tint: .purple)
                        }

                        StatisticsCard(title: .statsCompletedHistory, icon: "clock.arrow.circlepath", tint: .blue) {
                            VStack(spacing: 0) {
                                ForEach(historySessions.indices, id: \.self) { index in
                                    WorkoutSessionHistoryRow(session: historySessions[index])

                                    if index < historySessions.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(.screenStats)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.actionDone) {
                    dismiss()
                }
            }
        }
    }

    private var lastCompletedText: String {
        guard let lastCompletedDate = workout.lastCompletedDate else {
            return "–"
        }

        if Calendar.autoupdatingCurrent.isDate(lastCompletedDate, equalTo: .now, toGranularity: .year) {
            return lastCompletedDate.formatted(.dateTime.day().month(.abbreviated))
        }

        return lastCompletedDate.formatted(.dateTime.day().month(.abbreviated).year(.twoDigits))
    }

    private var historySessions: [Session] {
        Array(workout.completedSessionHistory.prefix(5))
    }
}

private struct WorkoutSessionHistoryRow: View {
    let session: Session

    var body: some View {
        HStack {
            Text(session.ended?.formatted(date: .abbreviated, time: .omitted) ?? "–")

            Spacer()

            if let ended = session.ended {
                Text(Duration.seconds(ended.timeIntervalSince(session.started))
                    .formatted(.time(pattern: .hourMinute(padHourToLength: 1))))
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        WorkoutStatisticsScreen(workout: Workout.samples[0])
    }
    .sampleData()
}
