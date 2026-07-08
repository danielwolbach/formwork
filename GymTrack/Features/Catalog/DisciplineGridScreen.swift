//
//  DisciplineGridScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct DisciplineGridScreen: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var sheet: ExerciseSheet?

    var body: some View {
        ScrollView {
            ScreenStack {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(Discipline.allCases) { discipline in
                        NavigationLink(value: discipline) {
                            DisciplineTile(discipline: discipline, count: exerciseCount(for: discipline))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Catalog")
        .navigationDestination(for: Discipline.self) { discipline in
            ExerciseList(exercises: exercises(for: discipline))
                .navigationTitle(discipline.name)
                .toolbar {
                    ToolbarItem {
                        Button(.createExercise) {
                            sheet = .createExerciseInDiscipline(discipline)
                        }
                    }
                }
        }
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseDetailScreen(exercise: exercise)
        }
        .toolbar {
            ToolbarItem {
                Button(.createExercise) {
                    sheet = .createExercise
                }
            }
        }
        .exerciseSheet(item: $sheet)
    }

    private func exercises(for discipline: Discipline) -> [Exercise] {
        exercises.filter { $0.disciplines.contains(discipline) }
    }

    private func exerciseCount(for discipline: Discipline) -> Int {
        exercises(for: discipline).count
    }
}

#Preview {
    NavigationStack {
        DisciplineGridScreen()
            .sampleData()
    }
}
