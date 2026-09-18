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

    var body: some View {
        ScrollView {
            ExerciseCategoryGrid(exercises: exercises)
                .padding(.horizontal)
        }
        .navigationTitle(.screenCatalogTitle)
        .navigationDestination(for: ExerciseCategory.self) { category in
            ExerciseCategoryScreen(category: category)
        }
        .toolbar {
            Button(.create) {
                sheet = .createExercise
            }
        }
        .sheet(item: $sheet) { $0 }
    }
}

private struct ExerciseCategoryGrid: View {
    let exercises: [Exercise]

    var body: some View {
        LazyVGrid(columns: [.init(.flexible(), spacing: 8), .init(.flexible(), spacing: 8)], spacing: 8) {
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
