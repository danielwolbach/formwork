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
    let workout: Workout?

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @State
    private var name: String

    @State
    private var pictogram: Pictogram

    @State
    private var schedule: Schedule

    @State
    private var entries: [WorkoutEntry]

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

                    PictogramEditor(imageOptions: Pictogram.workoutImageOptions, pictogram: $pictogram)

                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section(.sectionWorkoutNameTitle) {
                TextField(workout?.name ?? "", text: $name)
            }

            Section(.sectionWorkoutScheduleTitle) {
                ScheduleEditor(saved: workout?.schedule, schedule: $schedule)
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
        .scrollDismissesKeyboard(.interactively)
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
    private enum Rhythm {
        case weekly
        case daily
    }

    private static let weekIntervals = 1 ... 4

    private static let dayIntervals = 1 ... 14

    let saved: Schedule?

    @Binding
    var schedule: Schedule

    var body: some View {
        Picker(String(localized: .fieldScheduleRhythmTitle), selection: rhythm) {
            Text(.fieldScheduleRhythmWeeklyTitle)
                .tag(Rhythm.weekly)

            Text(.fieldScheduleRhythmDailyTitle)
                .tag(Rhythm.daily)
        }
        .pickerStyle(.segmented)
        .labelsHidden()

        switch schedule {
        case let .weekly(weekdays, interval, anchor):
            WeekdayPicker(weekdays: Binding(
                get: { weekdays },
                set: { new in
                    withAnimation(.snappy) {
                        // Picking the first weekday activates the schedule, so it starts now.
                        schedule = .weekly(weekdays: new, interval: interval, anchor: weekdays.isEmpty ? .now : anchor)
                    }
                }
            ))
            .listRowSeparator(.hidden)

            if !weekdays.isEmpty {
                intervalStepper(interval, in: Self.weekIntervals, title: .fieldScheduleWeeksTitle(interval)) {
                    .weekly(weekdays: weekdays, interval: $0, anchor: anchor)
                }

                startPicker(anchor) {
                    .weekly(weekdays: weekdays, interval: interval, anchor: $0)
                }
            }

        case let .daily(interval, anchor):
            intervalStepper(interval, in: Self.dayIntervals, title: .fieldScheduleDaysTitle(interval)) {
                .daily(interval: $0, anchor: anchor)
            }

            startPicker(anchor) {
                .daily(interval: interval, anchor: $0)
            }
        }
    }

    private var rhythm: Binding<Rhythm> {
        Binding(
            get: { Self.rhythm(of: schedule) },
            set: { rhythm in
                withAnimation(.snappy) {
                    if let saved, Self.rhythm(of: saved) == rhythm {
                        schedule = saved
                        return
                    }

                    switch (schedule, rhythm) {
                    case let (.weekly(weekdays, interval, anchor), .daily):
                        // A weekly schedule without weekdays was inactive, so the daily one it becomes starts now.
                        schedule = .daily(interval: min(interval, Self.dayIntervals.upperBound), anchor: weekdays.isEmpty ? .now : anchor)
                    case let (.daily(interval, anchor), .weekly):
                        schedule = .weekly(weekdays: [], interval: min(interval, Self.weekIntervals.upperBound), anchor: anchor)
                    default:
                        break
                    }
                }
            }
        )
    }

    private static func rhythm(of schedule: Schedule) -> Rhythm {
        switch schedule {
        case .weekly: .weekly
        case .daily: .daily
        }
    }

    private func intervalStepper(
        _ interval: Int,
        in range: ClosedRange<Int>,
        title: LocalizedStringResource,
        update: @escaping (Int) -> Schedule
    ) -> some View {
        Stepper(value: Binding(get: { interval }, set: { schedule = update($0) }), in: range) {
            Text(title)
        }
        .listRowSeparator(.hidden)
    }

    private func startPicker(_ anchor: Date, update: @escaping (Date) -> Schedule) -> some View {
        DatePicker(
            String(localized: .fieldScheduleStartTitle),
            selection: Binding(get: { anchor }, set: { schedule = update($0) }),
            displayedComponents: .date
        )
        .listRowSeparator(.hidden)
    }
}

private struct WeekdayPicker: View {
    @Binding
    var weekdays: Schedule.Weekdays

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
        .sensoryFeedback(.selection, trigger: weekdays)
    }

    private func binding(for candidate: Schedule.Weekday) -> Binding<Bool> {
        Binding(
            get: { weekdays.contains(candidate) },
            set: { selected in
                if selected {
                    weekdays.insert(Schedule.Weekdays([candidate]))
                } else {
                    weekdays.remove(Schedule.Weekdays([candidate]))
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
