//
//  ExerciseDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct ExerciseDetailScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var sheet: ExerciseSheet?
    @State private var deleteAlert = false

    let exercise: Exercise

    var body: some View {
        ScrollView {
            ScreenStack {
                ScreenSection {
                    IconHero(
                        icon: exercise.icon,
                        color: exercise.color,
                        title: exercise.title,
                        subtitle: exercise.subtitle
                    )

                    StatisticsStack {
                        StatisticsRowStack {
                            MetricCard(
                                value: lastPerformedText,
                                title: .statsLastPerformed,
                                icon: "calendar",
                                tint: .blue
                            )

                            MetricCard(
                                value: exercise.completedExecutionCount.formatted(),
                                title: .statsCompletedExecutions,
                                icon: "checkmark.circle",
                                tint: .green
                            )
                        }

                        StatisticsRowStack {
                            MetricCard(
                                value: exercise.lastTarget?.primaryTargetText ?? "–",
                                title: .statsLastTarget,
                                icon: "target",
                                tint: exercise.color,
                                trend: exercise.recentTargetTrend.map {
                                    MetricTrend(value: $0.value, direction: $0.isIncrease ? .up : .down)
                                }
                            )

                            MetricCard(
                                value: exercise.highestCompletedTarget?.primaryTargetText ?? "–",
                                title: .statsPersonalBest,
                                icon: "trophy",
                                tint: .yellow
                            )
                        }

                        StatisticsRowStack {
                            MetricCard(
                                value: exercise.completionRate?
                                    .formatted(.percent.precision(.fractionLength(0))) ?? "–",
                                title: .statsCompletionRate,
                                icon: "checkmark.seal",
                                tint: .green
                            )

                            MetricCard(
                                value: exercise.skippedExecutionCount.formatted(),
                                title: .statsSkippedExecutions,
                                icon: "forward.end",
                                tint: .orange
                            )
                        }

                        if !exercise.recentTargetHistory.isEmpty {
                            ExerciseTargetHistoryChart(data: exercise.recentTargetHistory, tint: exercise.color)
                        }

                        StatisticsCard(
                            title: .statsRecentActivity,
                            icon: "clock.arrow.circlepath",
                            tint: exercise.color
                        ) {
                            VStack(spacing: 0) {
                                ForEach(historyEntries.indices, id: \.self) { index in
                                    ExerciseHistoryRow(entry: historyEntries[index])

                                    if index < historyEntries.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            Menu(.moreOptions) {
                Section {
                    Button(.edit) {
                        sheet = .editExercise(exercise)
                    }
                }

                Section {
                    Button(.delete) {
                        deleteAlert = true
                    }
                }
            }
        }
        .exerciseSheet(item: $sheet)
        .alert(.alertDeleteExerciseTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertDeleteExerciseMessage)
        }
    }

    private func delete() {
        do {
            try modelContext.deleteExercise(exercise)
            dismiss()
        } catch {
            fatalError("Failed to delete exercise: \(error)")
        }
    }

    private var lastPerformedText: String {
        guard let lastPerformedDate = exercise.lastPerformedDate else {
            return "–"
        }

        if Calendar.autoupdatingCurrent.isDate(lastPerformedDate, equalTo: .now, toGranularity: .year) {
            return lastPerformedDate.formatted(.dateTime.day().month(.abbreviated))
        }

        return lastPerformedDate.formatted(.dateTime.day().month(.abbreviated).year(.twoDigits))
    }

    private var historyEntries: [SessionEntry] {
        Array(exercise.performedSessionEntries.prefix(5))
    }
}

private struct ExerciseHistoryRow: View {
    let entry: SessionEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.status.icon)
                .foregroundStyle(entry.status.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.session?.ended?.formatted(date: .abbreviated, time: .omitted) ?? "–")
                Text(entry.target.title)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .font(.subheadline)
        .padding(.vertical, 10)
    }
}

#Preview {
    ExerciseDetailScreen(exercise: Exercise.samples[0])
}
