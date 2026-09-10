//
//  ExerciseCategoryScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

struct ExerciseCategoryScreen: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var sheet: Sheet? = nil

    let category: ExerciseCategory

    var body: some View {
        ScreenStack {
            RowStack(navigating: filteredExercises)
        }
        .navigationTitle(category.title)
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseScreen(exercise: exercise)
        }
        .toolbar {
            Button(.create) {
                sheet = .createExercise
            }
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }

    private var filteredExercises: [Exercise] {
        exercises.filter { $0.categories.contains(category) }
    }
}

#Preview {
    NavigationStack {
        ExerciseCategoryScreen(category: .arms)
    }
    .sampleData()
}
