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
        var entries: [DraftEntry]
    }

    // Plain values until commit: a new WorkoutEntry pointing at a saved exercise would be inserted right away, and linger without a workout if the form is cancelled.
    private struct DraftEntry: Identifiable, Hashable {
        let id = UUID()
        let saved: WorkoutEntry?
        let exercise: Exercise?
        let target: ExerciseTarget

        var pictogram: Pictogram {
            saved?.pictogram ?? exercise?.pictogram ?? .unknown
        }

        var title: String {
            saved?.title ?? exercise?.title ?? ""
        }
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
            entries: (workout?.entries ?? []).sorted().map { DraftEntry(saved: $0, exercise: $0.exercise, target: $0.target) }
        )

        self.workout = workout
        self.original = draft
        self._draft = State(initialValue: draft)
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
                WorkoutAddEntriesForm { selection in
                    draft.entries += selection.map { DraftEntry(saved: nil, exercise: $0.exercise, target: $0.target) }
                }
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
                            .accessibilityHidden(true)
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
            .reorderContainer(for: DraftEntry.self) { difference in
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

    private var trimmedName: String {
        draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var valid: Bool {
        !trimmedName.isEmpty
    }

    private func commit() {
        let kept = Set(draft.entries.compactMap(\.saved))

        let entries = draft.entries.enumerated().map { index, item in
            let entry = item.saved ?? WorkoutEntry(exercise: item.exercise, target: item.target)
            entry.order = index
            return entry
        }

        if let workout {
            // Taken out of the workout, an entry would linger without one.
            for removed in workout.entries ?? [] where !kept.contains(removed) {
                context.delete(removed)
            }

            workout.name = trimmedName
            workout.pictogram = draft.pictogram
            workout.schedule = draft.schedule
            workout.entries = entries
        } else {
            let workout = Workout(name: trimmedName, pictogram: draft.pictogram, schedule: draft.schedule, entries: entries)
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
