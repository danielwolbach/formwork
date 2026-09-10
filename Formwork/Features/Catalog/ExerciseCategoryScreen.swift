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
    @State private var searchText = ""

    let category: ExerciseCategory

    var body: some View {
        Group {
            if categoryExercises.isEmpty {
                ContentUnavailableView {
                    Label(.emptyExercisesTitle, systemImage: category.pictogram.icon)
                } description: {
                    Text(.emptyExercisesMessage)
                } actions: {
                    Button(.create) {
                        sheet = .createExercise
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glassProminent)
                }
            } else {
                searchableExercises
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
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }

    private var searchableExercises: some View {
        Group {
            if matchingExercises.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ScreenStack {
                    RowStack(navigating: matchingExercises)
                }
            }
        }
        .searchable(text: $searchText.animated())
    }

    private var categoryExercises: [Exercise] {
        exercises.filter { $0.categories.contains(category) }
    }

    private var matchingExercises: [Exercise] {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if searchText.isEmpty {
            return categoryExercises
        } else {
            return categoryExercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseCategoryScreen(category: .arms)
    }
    .sampleData()
}
