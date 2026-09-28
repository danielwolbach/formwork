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
    private let category: Exercise.Category

    @Query(sort: \Exercise.name)
    private var exercises: [Exercise]

    @State
    private var searchText = ""

    @State
    private var sortOrder = [SortDescriptor(\Exercise.name)]

    @State
    private var sheet: Sheet?

    init(_ category: Exercise.Category) {
        self.category = category
    }

    var body: some View {
        let categoryExercises = categoryExercises
        let matching = matchingExercises(in: categoryExercises)

        Group {
            if categoryExercises.isEmpty {
                emptyState
            } else {
                ScrollView {
                    NavigationRows(for: matching) { exercise in
                        DisplayableRow(exercise)
                    }
                }
                .overlay {
                    if !trimmedSearchText.isEmpty, matching.isEmpty {
                        ContentUnavailableView.search(text: trimmedSearchText)
                    }
                }
                .searchable(text: $searchText)
            }
        }
        .navigationTitle(category.title)
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseScreen(exercise)
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.createExercise) {
                        sheet = .createExerciseInCategories([category])
                    }
                }

                Section {
                    Menu(.sort) {
                        Picker(.fieldSortTitle, selection: $sortOrder) {
                            Label(.fieldSortNameTitle, systemImage: "character")
                                .tag([SortDescriptor(\Exercise.name)])

                            Label(.fieldSortNewestTitle, systemImage: "clock")
                                .tag([SortDescriptor(\Exercise.creationDate, order: .reverse)])
                        }
                    }
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
        .animation(.snappy, value: searchText)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyExercisesTitle, systemImage: category.pictogram.image)
        } description: {
            Text(.emptyExercisesMessage)
        } actions: {
            Button(.createExercise) {
                sheet = .createExerciseInCategories([category])
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent())
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var categoryExercises: [Exercise] {
        exercises.filter { $0.categories.contains(category) }
    }

    private func matchingExercises(in exercises: [Exercise]) -> [Exercise] {
        let searchText = trimmedSearchText

        return exercises
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted(using: sortOrder)
    }
}

#Preview {
    NavigationStack {
        ExerciseCategoryScreen(.arms)
    }
    .sampleData()
}
