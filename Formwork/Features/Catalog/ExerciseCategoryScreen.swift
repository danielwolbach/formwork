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
        ScrollView {
            RowStack(items: exercises) { exercise in
                ExerciseRow(exercise: exercise)
            }
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

private struct ExerciseStack: View {
    let exercises: [Exercise]
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(exercises) { exercise in
                NavigationLink(value: exercise) {
                    ExerciseRow(exercise: exercise)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        NavigationRow(value: exercise) {
            DisplayableRow(displayable: exercise)
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseCategoryScreen(category: .arms)
    }
    .sampleData()
}
