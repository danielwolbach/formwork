//
//  CatalogScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct CatalogScreen: View {
    private enum Sort: Hashable {
        case category, name, newest

        var sortOrder: [SortDescriptor<Exercise>] {
            switch self {
            case .category, .name: [SortDescriptor(\.name)]
            case .newest: [SortDescriptor(\.creationDate, order: .reverse)]
            }
        }
    }

    @Query
    private var exercises: [Exercise]

    @State
    private var sort: Sort = .category

    @State
    private var searchText = ""

    @State
    private var searchPresented = false

    @State
    private var sheet: Sheet?

    var body: some View {
        let matching = matchingExercises

        ScrollView {
            if exercises.isEmpty {
                EmptyView()
            } else if sort == .category, !searchPresented {
                categoryGrid
                    .transition(.blurReplace)
            } else {
                exerciseList(matching)
                    .transition(.blurReplace)
            }
        }
        .animation(.snappy, value: sort)
        .animation(.snappy, value: searchText)
        .animation(.snappy, value: searchPresented)
        .searchable(text: $searchText, isPresented: $searchPresented)
        .navigationTitle(.screenCatalogTitle)
        .navigationDestination(for: Exercise.Category.self) { category in
            ExerciseCategoryScreen(category)
        }
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseScreen(exercise)
        }
        .overlay {
            emptyState(matching: matching)
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.createExercise) {
                        sheet = .createExercise
                    }
                }

                Section {
                    Menu(.sort) {
                        Picker(.fieldSortTitle, selection: $sort) {
                            Label(.fieldSortCategoryTitle, systemImage: "rectangle.grid.2x2")
                                .tag(Sort.category)

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
            NavigationStack {
                sheet
            }
        }
    }

    private var categoryGrid: some View {
        TileGrid {
            ForEach(Exercise.Category.allCases) { category in
                NavigationLink(value: category) {
                    ExerciseCategoryTile(category: category, exerciseCount: countExercises(in: category))
                }
            }
        }
        .padding(.horizontal)
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingExercises: [Exercise] {
        let searchText = trimmedSearchText

        return exercises
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted(using: sort.sortOrder)
    }

    private func exerciseList(_ exercises: [Exercise]) -> some View {
        NavigationRows(for: exercises) { exercise in
            DisplayableRow(exercise)
        }
    }

    @ViewBuilder
    private func emptyState(matching: [Exercise]) -> some View {
        if exercises.isEmpty {
            ContentUnavailableView {
                Label(.placeholder, systemImage: "dumbbell")
            } description: {
                Text(.placeholder)
            } actions: {
                Button(.createExercise) {
                    sheet = .createExercise
                }
            }
        } else if !trimmedSearchText.isEmpty, matching.isEmpty {
            ContentUnavailableView.search(text: trimmedSearchText)
        }
    }

    private func countExercises(in category: Exercise.Category) -> Int {
        exercises.count { $0.categories.contains(category) }
    }
}

private struct ExerciseCategoryTile: View {
    let category: Exercise.Category

    let exerciseCount: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: category.pictogram.image)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    Text(category.title)
                        .lineLimit(1)
                        .font(.headline)

                    Text(.placeholder)
                        .lineLimit(1)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
        }
        .foregroundStyle(.white)
        .card(category.pictogram.color)
    }
}

#Preview {
    NavigationStack {
        CatalogScreen()
    }
    .sampleData()
}
