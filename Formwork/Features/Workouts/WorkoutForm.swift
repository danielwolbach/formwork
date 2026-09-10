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
    @State private var isPictogramFormPresented = false

    let workout: Workout?

    init(workout: Workout? = nil) {
        self._name = State(initialValue: workout?.name ?? "")
        self._pictogram = State(initialValue: workout?.pictogram ?? Pictogram.workout)
        self._entries = State(initialValue: workout?.entries.sorted() ?? [])
        self._schedule = State(initialValue: workout?.schedule ?? .inactive)
        self.workout = workout
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()

                    Button {
                        isPictogramFormPresented = true
                    } label: {
                        PictogramView(
                            pictogram: pictogram,
                            size: 192,
                            badge: Pictogram(icon: "pencil.circle.fill", tint: .gray)
                        )
                    }

                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section(.fieldNameTitle) {
                TextField(workout?.name ?? String(localized: .fieldNameTitle), text: $name)
            }

            scheduleSection

            if !entries.isEmpty {
                Section(.fieldWorkoutEntriesTitle) {
                    ForEach(entries) { entry in
                        DisplayableRow(displayable: entry)
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
                    save()
                }
                .disabled(!valid)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $isPictogramFormPresented) {
            NavigationStack {
                PictogramForm(pictogram: $pictogram)
            }
        }
    }

    private var scheduleSection: some View {
        Section(.fieldWorkoutScheduleTitle) {
            WeekdayPicker(schedule: $schedule, tint: pictogram.color)

            if schedule.isActive {
                Picker(selection: $schedule.interval) {
                    ForEach(1 ... 4, id: \.self) { weeks in
                        Text(.fieldWorkoutScheduleIntervalValue(weeks)).tag(weeks)
                    }
                } label: {
                    Text(.fieldWorkoutScheduleIntervalTitle)
                }
                .listRowSeparator(.hidden)

                DatePicker(selection: $schedule.startDate, displayedComponents: .date) {
                    Text(.fieldWorkoutScheduleStartDateTitle)
                }
                .listRowSeparator(.hidden)
            }
        }
    }

    private var valid: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }

    private func save() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        for (index, entry) in entries.enumerated() {
            entry.order = index
        }

        if let workout {
            workout.name = name
            workout.pictogram = pictogram
            workout.schedule = schedule
        } else {
            let workout = Workout(name: name, pictogram: pictogram, entries: entries, schedule: schedule)
            modelContext.insert(workout)
        }

        dismiss()
    }
}

private struct WeekdayPicker: View {
    @Binding var schedule: Schedule
    let tint: Color

    var body: some View {
        HStack {
            ForEach(Weekday.ordered()) { candidate in
                WeekdayChip(day: candidate, tint: tint, isSelected: schedule.days.contains(candidate)) {
                    schedule.setDay(candidate, isOn: !schedule.days.contains(candidate))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .sensoryFeedback(.selection, trigger: schedule.days)
    }
}

private struct WeekdayChip: View {
    let day: Weekday
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectableTile(
            outline: Circle(),
            tint: tint,
            isSelected: isSelected,
            action: action
        ) {
            Text(day.symbol())
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .frame(width: 40, height: 40)
        }
        .accessibilityLabel(day.name())
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
