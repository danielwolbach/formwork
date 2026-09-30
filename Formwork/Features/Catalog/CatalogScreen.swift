//
//  CatalogScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
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

        Group {
            if exercises.isEmpty {
                emptyState
            } else {
                ScrollView {
                    ContentStack {
                        if sort == .category, !searchPresented {
                            categoryGrid
                                .transition(.blurReplace)
                        } else {
                            exerciseList(matching)
                                .transition(.blurReplace)
                        }
                    }
                }
                .contentMargins(.bottom, .sections, for: .scrollContent)
                .overlay {
                    if !trimmedSearchText.isEmpty, matching.isEmpty {
                        ContentUnavailableView.search(text: trimmedSearchText)
                    }
                }
                .searchable(text: $searchText, isPresented: $searchPresented)
            }
        }
        .animation(.snappy, value: sort)
        .animation(.snappy, value: searchText)
        .animation(.snappy, value: searchPresented)
        .navigationTitle(.screenCatalogTitle)
        .navigationDestination(for: Exercise.Category.self) { category in
            ExerciseCategoryScreen(category)
        }
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseScreen(exercise)
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
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyExercisesTitle, systemImage: "dumbbell")
        } description: {
            Text(.emptyExercisesMessage)
        } actions: {
            Button(.createExercise) {
                sheet = .createExercise
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent)
        }
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
        LazyVStack(spacing: 0) {
            ForEach(exercises) { exercise in
                ExerciseRow(exercise)
            }
        }
        .swipeActionsContainer()
        .animation(.snappy, value: exercises.count)
        .edgeToEdge()
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

                    Text(exerciseCount.formatted(.exerciseCount))
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
        .background(category.pictogram.color, in: .rect(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        CatalogScreen()
    }
    .sampleData()
}
