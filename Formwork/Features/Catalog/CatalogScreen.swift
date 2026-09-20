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
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var sheet: Sheet? = nil
    @State private var searchText = ""

    var body: some View {
        content
            .navigationTitle(.screenCatalogTitle)
            .navigationDestination(for: ExerciseCategory.self) { category in
                ExerciseCategoryScreen(category: category)
            }
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseScreen(exercise: exercise)
            }
            .toolbar {
                Button(.create) {
                    sheet = .createExercise
                }
            }
            .sheet(item: $sheet) { $0 }
    }

    @ViewBuilder
    private var content: some View {
        if exercises.isEmpty {
            ContentUnavailableView {
                Label(.emptyExercisesTitle, systemImage: "dumbbell")
            } description: {
                Text(.emptyExercisesDescription)
            } actions: {
                Button(.create) {
                    sheet = .createExercise
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
        if trimmedSearchText.isEmpty {
            ScrollView {
                ExerciseCategoryGrid(exercises: exercises)
                    .padding(.horizontal)
            }
        } else if matchingExercises.isEmpty {
            ContentUnavailableView.search(text: trimmedSearchText)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(matchingExercises) { exercise in
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
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingExercises: [Exercise] {
        exercises.filter { $0.name.localizedCaseInsensitiveContains(trimmedSearchText) }
    }
}

private struct ExerciseCategoryGrid: View {
    let exercises: [Exercise]

    var body: some View {
        LazyVGrid(columns: GridItem.ntile(n: 2, spacing: 8), spacing: 8) {
            ForEach(ExerciseCategory.allCases) { category in
                NavigationLink(value: category) {
                    ExerciseCategoryTile(category: category, exerciseCount: countExercises(in: category))
                }
            }
        }
    }

    private func countExercises(in category: ExerciseCategory) -> Int {
        exercises.count { $0.categories.contains(category) }
    }
}

private struct ExerciseCategoryTile: View {
    let category: ExerciseCategory
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

                    Text(Exercise.countTitle(exerciseCount))
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
        }
        .foregroundStyle(.white)
        .background(category.pictogram.color)
        .aspectRatio(1.8, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .contentShape(.rect)
    }
}

#Preview {
    NavigationStack {
        CatalogScreen()
    }
    .sampleData()
}
