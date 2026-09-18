//
//  ExerciseCategoryScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct ExerciseCategoryScreen: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var sheet: Sheet? = nil

    let category: ExerciseCategory

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(categoryExercises) { exercise in
                    NavigationLink(value: exercise) {
                        PictogramRow(exercise)

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle(category.title)
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseScreen(exercise: exercise)
        }
        .toolbar {
            Button(.create) {
                sheet = .createExerciseInCategory(category: category)
            }
        }
        .sheet(item: $sheet) { $0 }
    }

    private var categoryExercises: [Exercise] {
        exercises.filter { $0.categories.contains(category) }
    }
}

#Preview {
    NavigationStack {
        ExerciseCategoryScreen(category: .arms)
    }
    .sampleData()
}
