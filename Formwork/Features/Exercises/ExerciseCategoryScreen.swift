//
//  ExerciseCategoryScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct ExerciseCategoryScreen: View {
    private enum Sort: Hashable {
        case name, newest

        var descriptor: [SortDescriptor<Exercise>] {
            switch self {
            case .name: [SortDescriptor(\.name)]
            case .newest: [SortDescriptor(\.creationDate, order: .reverse)]
            }
        }
    }

    private let category: Exercise.Category

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.paywall)
    private var paywall: Paywall

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(filter: #Predicate<Exercise> { !$0.isArchived })
    private var exercises: [Exercise]

    @State
    private var searchText: String = ""

    @State
    private var sort: Sort = .name

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
                    LazyVStack(spacing: 0) {
                        ForEach(matching) { exercise in
                            ExerciseRow(exercise)
                        }
                    }
                    .swipeActionsContainer()
                    .animation(.snappy, value: matching.count)
                }
                .contentMargins(.bottom, .sections, for: .scrollContent)
                .overlay {
                    if !trimmedSearchText.isEmpty, matching.isEmpty {
                        ContentUnavailableView.search(text: trimmedSearchText)
                    }
                }
                .searchable(text: $searchText)
            }
        }
        .navigationTitle(category.title)
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.createExercise) {
                        createExercise()
                    }
                }

                Section {
                    Menu(.sort) {
                        Picker(.fieldSortTitle, selection: $sort) {
                            Label(.fieldSortNameTitle, systemImage: "character")
                                .tag(Sort.name)

                            Label(.fieldSortNewestTitle, systemImage: "clock")
                                .tag(Sort.newest)
                        }
                    }
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
        .animation(.snappy, value: searchText)
        .animation(.snappy, value: sort)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyExercisesTitle, systemImage: category.pictogram.image)
        } description: {
            Text(.emptyExercisesMessage)
        } actions: {
            Button(.createExercise) {
                createExercise()
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent)
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
            .sorted(using: sort.descriptor)
    }

    private func createExercise() {
        if paywall.canAddExercise(in: context) {
            sheet = .createExerciseInCategories([category])
        } else {
            presentPaywall()
        }
    }
}

#Preview {
    NavigationRoot {
        ExerciseCategoryScreen(.mindfulness)
    }
    .sampleData()
}
