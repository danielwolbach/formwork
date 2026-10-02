//
//  ArchiveScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct ArchiveScreen: View {
    @Query(filter: #Predicate<Workout> { $0.isArchived }, sort: \Workout.name)
    private var archivedWorkouts: [Workout]

    @Query(filter: #Predicate<Exercise> { $0.isArchived }, sort: \Exercise.name)
    private var archivedExercises: [Exercise]

    var body: some View {
        Group {
            if archivedWorkouts.isEmpty, archivedExercises.isEmpty {
                ContentUnavailableView {
                    Label(.emptyArchiveTitle, systemImage: "archivebox")
                } description: {
                    Text(.emptyArchiveMessage)
                }
            } else {
                ScrollView {
                    ContentStack {
                        if !archivedWorkouts.isEmpty {
                            SectionView(String(localized: .fieldWorkoutsTitle)) {
                                LazyVStack(spacing: 0) {
                                    ForEach(archivedWorkouts) { workout in
                                        WorkoutRow(workout)
                                    }
                                }
                                .swipeActionsContainer()
                                .edgeToEdge()
                            }
                        }

                        if !archivedExercises.isEmpty {
                            SectionView(String(localized: .fieldExercisesTitle)) {
                                LazyVStack(spacing: 0) {
                                    ForEach(archivedExercises) { exercise in
                                        ExerciseRow(exercise)
                                    }
                                }
                                .swipeActionsContainer()
                                .edgeToEdge()
                            }
                        }
                    }
                }
                .contentMargins(.bottom, .sections, for: .scrollContent)
            }
        }
        .animation(.snappy, value: archivedWorkouts.count)
        .animation(.snappy, value: archivedExercises.count)
        .navigationTitle(.screenArchiveTitle)
        .navigationDestination(for: Workout.self) { workout in
            WorkoutScreen(workout)
        }
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseScreen(exercise)
        }
    }
}

#Preview {
    let _ = Samples.workouts.suffix(2).forEach { $0.isArchived = true }
    let _ = Samples.exercises.suffix(4).forEach { $0.isArchived = true }

    NavigationStack {
        ArchiveScreen()
    }
    .sampleData()
}
