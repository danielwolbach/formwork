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
    @Query private var exercises: [Exercise]
    @State private var sheet: Sheet? = nil
    
    var body: some View {
        ScrollView {
            ExerciseCategoryGrid(exercises: exercises)
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
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }
}

private struct ExerciseCategoryGrid: View {
    let exercises: [Exercise]
    
    var body: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
            ForEach(ExerciseCategory.allCases) { category in
                NavigationLink(value: category) {
                    ExerciseCategoryTile(category: category, exerciseCount: countExercises(in: category))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
    
    private func countExercises(in category: ExerciseCategory) -> Int {
        return exercises.count { $0.categories.contains(category) }
    }
}

private struct ExerciseCategoryTile: View {
    let category: ExerciseCategory
    let exerciseCount: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: category.pictogram.icon)
                .padding(8)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    Text(category.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(.exerciseCategorySubtitle(exerciseCount: exerciseCount))
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
        }
        .foregroundStyle(.white)
        .aspectRatio(1.8, contentMode: .fit)
        .glassEffect(.regular.tint(category.pictogram.color), in: .rect(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 4)
        .contentShape(.rect)
    }
}


#Preview {
    NavigationStack {
        CatalogScreen()
    }
    .sampleData()
}
