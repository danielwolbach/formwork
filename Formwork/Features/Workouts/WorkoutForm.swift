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
    private let workout: Workout?

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var name: String = ""

    @State
    private var pictogram: Pictogram = .workout

    @State
    private var schedule: Schedule = .weekly()

    @State
    private var entries: [WorkoutEntry] = []

    @State
    private var showEntriesPicker: Bool = false

    init(_ workout: Workout? = nil) {
        self.workout = workout
        self._name = .init(initialValue: workout?.name ?? "")
        self._pictogram = .init(initialValue: workout?.pictogram ?? .workout)
        self._schedule = .init(initialValue: workout?.schedule ?? .weekly())
        self._entries = .init(initialValue: workout?.entries.sorted() ?? [])
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                PictogramEditor($pictogram)
                    .frame(width: 192)

                SectionView(.init(localized: .fieldNameTitle)) {
                    TextField(.fieldNamePlaceholder, text: $name)
                        .padding()
                        .card()
                        .padding(.horizontal)
                }

                SectionView(.init(localized: .fieldScheduleTitle)) {
                    ScheduleEditor($schedule, saved: workout?.schedule)
                        .padding()
                        .card()
                        .padding(.horizontal)
                }

                SectionView(.init(localized: .fieldExercisesTitle)) {
                    entriesEditor
                        .animation(.default, value: entries)
                } accessory: {
                    if !entries.isEmpty {
                        Button(.addExercise) {
                            showEntriesPicker = true
                        }
                        .labelStyle(.fixedTitleAndIcon)
                        .buttonStyle(.cardProminent())
                    }
                }
            }
        }
        .navigationTitle(workout == nil ? .screenCreateWorkoutTitle : .screenEditWorkoutTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    commit()
                }
                .disabled(!valid)
            }
        }
        .sheet(isPresented: $showEntriesPicker) {
            NavigationStack {
                WorkoutAddEntriesForm(entries: $entries)
            }
        }
    }

    @ViewBuilder
    private var entriesEditor: some View {
        if entries.isEmpty {
            ContentUnavailableView {
                Label(.emptyWorkoutEntriesTitle, systemImage: "dumbbell")
            } description: {
                Text(.emptyWorkoutEntriesMessage)
            } actions: {
                Button(.addExercise) {
                    showEntriesPicker = true
                }
                .labelStyle(.fixedTitleAndIcon)
                .buttonStyle(.cardProminent())
            }
            .padding()
            .card()
            .padding(.horizontal)
        } else {
            LazyVStack(spacing: 0) {
                ForEach(entries) { entry in
                    HStack {
                        DisplayableRow(entry)

                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .swipeActions {
                        Button(.remove) {
                            entries.removeAll { $0.id == entry.id }
                        }
                        .labelStyle(.fixedIconOnly)
                    }
                }
                .reorderable()
            }
            .reorderContainer(for: WorkoutEntry.self) { difference in
                entries.apply(difference: difference)
            }
            .padding(.vertical, 8)
            .card()
            .padding(.horizontal)
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
            // Taken out of the workout, an entry would linger without one.
            for removed in workout.entries where !entries.contains(removed) {
                context.delete(removed)
            }

            workout.name = name
            workout.pictogram = pictogram
            workout.schedule = schedule
            workout.entries = entries
        } else {
            let workout = Workout(name: name, pictogram: pictogram, schedule: schedule, entries: entries)
            context.insert(workout)
        }

        dismiss()
    }
}

extension Array where Element: Identifiable, Element.ID: Sendable {
    fileprivate mutating func apply(difference: ReorderDifference<Element.ID, some Hashable & Sendable>) {
        let moved = filter { difference.sources.contains($0.id) }
        removeAll { difference.sources.contains($0.id) }

        switch difference.destination.position {
        case let .before(id):
            guard let index = firstIndex(where: { $0.id == id }) else {
                return
            }
            insert(contentsOf: moved, at: index)
        case .end:
            append(contentsOf: moved)
        }
    }
}

#Preview("Create") {
    NavigationStack {
        WorkoutForm()
    }
    .sampleData()
}

#Preview("Edit") {
    NavigationStack {
        WorkoutForm(Samples.workouts.first!)
    }
    .sampleData()
}
