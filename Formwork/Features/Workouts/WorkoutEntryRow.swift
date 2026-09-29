//
//  WorkoutEntryRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 29.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutEntryRow: View {
    private let entry: WorkoutEntry

    @Environment(\.modelContext)
    private var context: ModelContext

    @State
    private var removeAlert: Bool = false

    @State
    private var sheet: Sheet? = nil

    init(_ entry: WorkoutEntry) {
        self.entry = entry
    }

    var body: some View {
        NavigationLink(value: entry) {
            HStack {
                DisplayableRow(entry)

                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
            }
            .padding(8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .swipeActions {
            // No destructive role: it makes SwiftUI expect the row to disappear, so cancelling the alert leaves the button stuck.
            Button(Action.remove.title, systemImage: Action.remove.image) {
                removeAlert = true
            }
            .tint(.red)
            .labelStyle(.fixedIconOnly)
        }
        .swipeActions(edge: .leading) {
            Button(.viewStatistics) {
                sheet = .workoutEntryStatistics(entry)
            }
            .labelStyle(.fixedIconOnly)
        }
        .contextMenu {
            Section {
                Button(.viewStatistics) {
                    sheet = .workoutEntryStatistics(entry)
                }
            }

            Section {
                if let exercise = entry.exercise {
                    Button(.edit) {
                        sheet = .editExercise(exercise)
                    }
                }

                Button(.remove) {
                    removeAlert = true
                }
            }
        } preview: {
            let history = History(.entry(entry))

            VStack(spacing: 16) {
                DisplayableRow(entry)

                if !history.sessions.isEmpty {
                    TileGrid {
                        StatisticCard(.lastCompleted, of: history)

                        StatisticCard(.completionRate, of: history)

                        StatisticCard(.personalBest, of: history)

                        StatisticCard(.completions, of: history)

                        StatisticCard(.typicalDuration, of: history)

                        StatisticCard(.typicalInterval, of: history)
                    }
                }
            }
            .frame(width: 360)
            .padding()
        }
        .alert(.alertRemoveWorkoutEntryTitle, isPresented: $removeAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.remove) {
                remove()
            }
        } message: {
            Text(.alertRemoveWorkoutEntryMessage)
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
        .padding(.horizontal, 8)
    }

    private func remove() {
        context.delete(entry)
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryRow(Samples.workouts.first!.entries.first!)
    }
    .sampleData()
}
