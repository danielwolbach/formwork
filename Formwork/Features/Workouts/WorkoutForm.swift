//
//  WorkoutForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutForm: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var name: String
    @State private var pictogram: Pictogram
    @State private var schedule: Schedule
    @State private var entries: [WorkoutEntry]

    let workout: Workout?

    init(workout: Workout? = nil) {
        self._name = State(initialValue: workout?.name ?? "")
        self._pictogram = State(initialValue: workout?.pictogram ?? .workout)
        self._entries = State(initialValue: workout?.entries.sorted() ?? [])
        self._schedule = State(initialValue: workout?.schedule ?? .inactive)
        self.workout = workout
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()

                    PictogramEditor(pictogram: $pictogram)

                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section(.sectionWorkoutNameTitle) {
                TextField(workout?.name ?? "", text: $name)
            }

            Section(.sectionWorkoutScheduleTitle) {
                ScheduleEditor(schedule: $schedule)
            }

            if !entries.isEmpty {
                Section(.sectionWorkoutExercisesTitle) {
                    ForEach(entries) { entry in
                        PictogramRow(entry)
                    }
                    .onMove { source, destination in
                        entries.move(fromOffsets: source, toOffset: destination)
                    }
                }
            }
        }
        .navigationTitle(workout == nil ? .screenWorkoutCreateTitle : .screenWorkoutEditTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    commit()
                    dismiss()
                }
                .disabled(!valid)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
    }

    private var valid: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }

    private func commit() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        for (index, entry) in entries.enumerated() {
            entry.order = index
        }

        if let workout {
            workout.name = name
            workout.pictogram = pictogram
            workout.schedule = schedule
        } else {
            let workout = Workout(name: name, pictogram: pictogram, schedule: schedule, entries: entries)
            modelContext.insert(workout)
        }
    }
}

private struct ScheduleEditor: View {
    @Binding var schedule: Schedule

    var body: some View {
        LazyVGrid(columns: GridItem.ntile(n: 7, spacing: 0), spacing: 0) {
            ForEach(Schedule.Weekday.ordered()) { weekday in
                Toggle(isOn: binding(for: weekday)) {
                    Text(weekday.symbol())
                        .font(.headline)
                        .padding(4)
                }
                .toggleStyle(.card())
                .buttonBorderShape(.circle)
                .accessibilityLabel(weekday.name())
            }
        }
        .sensoryFeedback(.selection, trigger: schedule.weekdays)
    }

    private func binding(for candidate: Schedule.Weekday) -> Binding<Bool> {
        Binding(
            get: { schedule.weekdays.contains(candidate) },
            set: { selected in
                if selected {
                    schedule.weekdays.insert(candidate)
                } else {
                    schedule.weekdays.remove(candidate)
                }
            }
        )
    }
}

#Preview("Create") {
    NavigationStack {
        WorkoutForm()
    }
}

#Preview("Edit") {
    NavigationStack {
        WorkoutForm(workout: Samples.workouts.first!)
    }
}
