//
//  WorkoutForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutForm: View {
    private struct Draft: Equatable {
        var name: String
        var pictogram: Pictogram
        var schedule: Schedule
        var entries: [WorkoutEntry]
    }

    private let workout: Workout?

    private let original: Draft

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.units)
    private var units: Units

    @State
    private var draft: Draft

    @State
    private var showEntriesPicker: Bool = false

    init(_ workout: Workout? = nil) {
        let draft = Draft(
            name: workout?.name ?? "",
            pictogram: workout?.pictogram ?? .workout,
            schedule: workout?.schedule ?? .weekly(),
            entries: workout?.entries.sorted() ?? []
        )

        self.workout = workout
        self.original = draft
        self._draft = .init(initialValue: draft)
    }

    var body: some View {
        ScrollView {
            ContentStack {
                PictogramEditor($draft.pictogram)
                    .frame(width: 192)

                SectionView(.fieldNameTitle) {
                    GroupBox {
                        TextField(.fieldNamePlaceholder, text: $draft.name)
                    }
                }

                SectionView(.fieldScheduleTitle) {
                    GroupBox {
                        ScheduleEditor($draft.schedule, saved: workout?.schedule)
                    }
                }

                SectionView(.fieldExercisesTitle) {
                    entriesEditor
                        .animation(.default, value: draft.entries)
                } accessory: {
                    if !draft.entries.isEmpty {
                        Button(.addExercises) {
                            showEntriesPicker = true
                        }
                        .labelStyle(.fixedTitleAndIcon)
                        .buttonStyle(.cardProminent)
                    }
                }
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .groupBoxStyle(.card)
        .navigationTitle(workout == nil ? .screenCreateWorkoutTitle : .screenEditWorkoutTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .interactiveDismissDisabled(hasChanges)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton(hasChanges: hasChanges)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    commit()
                }
                .disabled(!valid)
            }
        }
        .sheet(isPresented: $showEntriesPicker) {
            NavigationRoot {
                WorkoutAddEntriesForm(entries: $draft.entries)
            }
            .paywallPresenter()
        }
    }

    @ViewBuilder
    private var entriesEditor: some View {
        if draft.entries.isEmpty {
            GroupBox {
                ContentUnavailableView {
                    Label(.emptyWorkoutEntriesTitle, systemImage: "dumbbell")
                } description: {
                    Text(.emptyWorkoutEntriesMessage)
                } actions: {
                    Button(.addExercises) {
                        showEntriesPicker = true
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.cardProminent)
                }
            }
        } else {
            LazyVStack(spacing: 0) {
                ForEach(draft.entries) { entry in
                    HStack {
                        PictogramRow(entry.pictogram, title: entry.title, subtitle: entry.target.formatted(.exerciseTarget(units: units)))

                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .swipeActions {
                        Button(.remove) {
                            draft.entries.removeAll { $0.id == entry.id }
                        }
                        .labelStyle(.fixedIconOnly)
                    }
                }
                .reorderable()
            }
            .reorderContainer(for: WorkoutEntry.self) { difference in
                draft.entries.apply(difference: difference)
            }
            .swipeActionsContainer()
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
        }
    }

    private var hasChanges: Bool {
        draft != original
    }

    private var valid: Bool {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }

    private func commit() {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)

        for (index, entry) in draft.entries.enumerated() {
            entry.order = index
        }

        if let workout {
            // Taken out of the workout, an entry would linger without one.
            for removed in workout.entries where !draft.entries.contains(removed) {
                context.delete(removed)
            }

            workout.name = name
            workout.pictogram = draft.pictogram
            workout.schedule = draft.schedule
            workout.entries = draft.entries
        } else {
            let workout = Workout(name: name, pictogram: draft.pictogram, schedule: draft.schedule, entries: draft.entries)
            context.insert(workout)
        }

        dismiss()
    }
}

#Preview("Create") {
    NavigationRoot {
        WorkoutForm()
    }
    .sampleData()
}

#Preview("Edit") {
    NavigationRoot {
        WorkoutForm(Samples.workouts.first!)
    }
    .sampleData()
}
