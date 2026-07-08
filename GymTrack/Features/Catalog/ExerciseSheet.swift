//
//  ExerciseSheet.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

enum ExerciseSheet: Identifiable {
    case createExercise
    case createExerciseInDiscipline(Discipline)
    case editExercise(Exercise)

    var id: String {
        switch self {
        case .createExercise: "createExercise"
        case let .createExerciseInDiscipline(discipline): "createExerciseInDiscipline-\(discipline.id)"
        case let .editExercise(exercise): "editExercise-\(exercise.persistentModelID)"
        }
    }
}

extension View {
    func exerciseSheet(item: Binding<ExerciseSheet?>) -> some View {
        sheet(item: item) { sheet in
            NavigationStack {
                switch sheet {
                case .createExercise: ExerciseFormScreen()
                case let .createExerciseInDiscipline(discipline): ExerciseFormScreen(disciplines: [discipline])
                case let .editExercise(exercise): ExerciseFormScreen(exercise: exercise)
                }
            }
        }
    }
}
