//
//  ExerciseAddToWorkoutForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct ExerciseAddToWorkoutForm: View {
    private let exercise: Exercise

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.units)
    private var units: Units

    @Query(filter: #Predicate<Workout> { !$0.isArchived })
    private var activeWorkouts: [Workout]

    @State
    private var selection: Workout?

    @State
    private var target: ExerciseTarget?

    @State
    private var sheet: Sheet?

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        let workout = selection ?? workouts.first

        Group {
            if let workout {
                ScrollView {
                    ContentStack {
                        SectionView(.init(localized: .fieldWorkoutTitle)) {
                            GroupBox {
                                workoutPicker(workout)
                            }
                        }

                        SectionView(.init(localized: .fieldTargetTitle)) {
                            GroupBox {
                                ExerciseTargetEditor(target: targetBinding)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .contentMargins(.bottom, .sections, for: .scrollContent)
                .groupBoxStyle(.card)
            } else {
                emptyState
            }
        }
        .navigationTitle(.screenAddToWorkoutTitle)
        .navigationSubtitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: selection)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    commit(to: workout)
                }
                .disabled(workout == nil)
            }
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyWorkoutsTitle, systemImage: "clipboard")
        } description: {
            Text(.emptyWorkoutsMessage)
        } actions: {
            Button(.createWorkout) {
                sheet = .createWorkout
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent)
        }
    }

    private var workouts: [Workout] {
        activeWorkouts.sorted { lastActivity(of: $0) > lastActivity(of: $1) }
    }

    private var targetBinding: Binding<ExerciseTarget> {
        Binding(
            get: { target ?? initialTarget },
            set: { target = $0 }
        )
    }

    private var initialTarget: ExerciseTarget {
        exercise.currentHighestTarget ?? .initial(for: exercise.kind, in: units)
    }

    private func workoutPicker(_ workout: Workout) -> some View {
        Menu {
            Picker(.fieldWorkoutTitle, selection: Binding(get: { workout }, set: { selection = $0 })) {
                ForEach(workouts) { workout in
                    Label(workout.title, systemImage: workout.pictogram.image)
                        .tag(workout)
                }
            }
            .pickerStyle(.inline)
        } label: {
            HStack {
                PictogramRow(workout.pictogram, title: workout.title, subtitle: workout.formatted(.workoutDetails))

                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.tertiary)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private func lastActivity(of workout: Workout) -> Date {
        workout.sessions.map(\.startDate).reduce(workout.creationDate, max)
    }

    private func commit(to workout: Workout?) {
        workout?.append(exercise: exercise, target: target ?? initialTarget)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ExerciseAddToWorkoutForm(Samples.exercises.first!)
    }
    .sampleData()
}
