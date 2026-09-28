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

        ScrollView {
            NavigationRows(for: matching) { exercise in
                DisplayableRow(exercise)
            }
        }
        .overlay {
            if categoryExercises.isEmpty {
                ContentUnavailableView {
                    Label(.placeholder, systemImage: category.pictogram.image)
                } description: {
                    Text(.placeholder)
                } actions: {
                    Button(.createExercise) {
                        sheet = .createExerciseInCategories([category])
                    }
                }
            } else if !trimmedSearchText.isEmpty, matching.isEmpty {
                ContentUnavailableView.search(text: trimmedSearchText)
            }
        }
        .navigationTitle(category.title)
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseScreen(exercise)
        }
        .searchable(text: $searchText)
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

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var categoryExercises: [Exercise] {
        exercises.filter { $0.categories.contains(category) }
    }

    private func matchingExercises(in exercises: [Exercise]) -> [Exercise] {
        let searchText = trimmedSearchText

        return searchText.isEmpty ? exercises : exercises
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted(using: sortOrder)
    }
}

#Preview {
    NavigationStack {
        ExerciseCategoryScreen(.arms)
    }
    .sampleData()
}
