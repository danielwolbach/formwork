//
//  Sheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

enum Sheet: Identifiable, Hashable, View {
    case createExercise
    case createExerciseInCategories(_ categories: Set<Exercise.Category>)
    case editExercise(_ exercise: Exercise)
    case editExerciseNotes(_ exercise: Exercise)
    case createWorkout
    case editWorkout(_ workout: Workout)
    case workoutAddEntries(_ workout: Workout)
    case workoutStatistics(_ workout: Workout)
    case workoutEntryStatistics(_ entry: WorkoutEntry)
    case exerciseGuide(_ exercise: Exercise)
    case settings

    var body: some View {
        // Outside the stack: pushed screens take the stack's environment, not its root view's, so a presenter inside would never reach them.
        NavigationStack {
            content
        }
        .paywallPresenter()
    }

    @ViewBuilder
    private var content: some View {
        switch self {
        case .createExercise: ExerciseForm()
        case let .createExerciseInCategories(categories): ExerciseForm(categories: categories)
        case let .editExercise(exercise): ExerciseForm(exercise)
        case let .editExerciseNotes(exercise): ExerciseNotesSheet(exercise)
        case .createWorkout: WorkoutForm()
        case let .editWorkout(workout): WorkoutForm(workout)
        case let .workoutAddEntries(workout): WorkoutAddEntriesForm(workout: workout)
        case let .workoutStatistics(workout): WorkoutStatisticsScreen(workout)
        case let .workoutEntryStatistics(entry): WorkoutEntryStatisticsScreen(entry)
        case let .exerciseGuide(exercise): ExerciseGuideSheet(exercise)
        case .settings: SettingsScreen()
        }
    }

    var id: Self {
        self
    }
}
