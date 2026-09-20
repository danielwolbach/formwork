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
        content
            .navigationTitle(category.title)
            .toolbar {
                Button(.create) {
                    sheet = .createExerciseInCategory(category: category)
                }
            }
            .sheet(item: $sheet) { $0 }
    }

    @ViewBuilder
    private var content: some View {
        if categoryExercises.isEmpty {
            ContentUnavailableView {
                Label(.emptyExercisesTitle, systemImage: category.pictogram.image)
            } description: {
                Text(.emptyCategoryDescription)
            } actions: {
                Button(.create) {
                    sheet = .createExerciseInCategory(category: category)
                }
                .buttonStyle(.glassProminent)
            }
        } else {
            searchContent
                .searchable(text: $searchText.animated())
        }
    }

    @ViewBuilder
    private var searchContent: some View {
        if matchingExercises.isEmpty {
            ContentUnavailableView.search(text: trimmedSearchText)
        } else {
            ScrollView {
                NavigationList(matchingExercises) { exercise in
                    PictogramRow(exercise)
                }
            }
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingExercises: [Exercise] {
        guard !trimmedSearchText.isEmpty else { return categoryExercises }
        return categoryExercises.filter { $0.name.localizedCaseInsensitiveContains(trimmedSearchText) }
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
