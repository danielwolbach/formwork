//
//  WorkoutExercisePicker.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutExercisePicker: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var selectedDisciplines: Set<Discipline> = []
    @State private var searchText = ""
    @State private var createSheet = false

    let workout: Workout

    var body: some View {
        content
            .navigationTitle(.screenAddExercise)
            .navigationSubtitle(workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: .searchExercises)
            .safeAreaInset(edge: .bottom) {
                if !exercises.isEmpty {
                    DisciplineFilterBar(selection: $selectedDisciplines)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(.createExercise) {
                        createSheet = true
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(.cancel) {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: Exercise.self) { exercise in
                WorkoutExerciseTargetScreen(
                    exercise: exercise,
                    workout: workout,
                    dismissPicker: dismiss
                )
            }
            .sheet(isPresented: $createSheet) {
                NavigationStack {
                    ExerciseFormScreen(disciplines: selectedDisciplines)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if exercises.isEmpty {
            ContentUnavailableView(.emptyNoExercises, systemImage: Exercise.genericIcon)
        } else if matchingExercises.isEmpty {
            emptyState
        } else {
            ScrollView {
                ScreenStack {
                    ExerciseList(exercises: matchingExercises)
                }
            }
        }
    }

    private var matchingExercises: [Exercise] {
        let byDiscipline = selectedDisciplines.isEmpty
            ? exercises
            : exercises.filter { selectedDisciplines.isSubset(of: $0.disciplines) }

        guard hasSearchText else {
            return byDiscipline
        }

        return byDiscipline.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedSearchText)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if hasSearchText {
            ContentUnavailableView.search(text: searchText)
        } else {
            ContentUnavailableView(
                .emptyNoMatchingExercises,
                systemImage: Exercise.genericIcon,
                description: Text(.emptyNoMatchingExercisesDescription)
            )
        }
    }

    private var hasSearchText: Bool {
        !trimmedSearchText.isEmpty
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct DisciplineFilterBar: View {
    @Binding var selection: Set<Discipline>

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(Discipline.allCases) { discipline in
                    DisciplineFilterButton(
                        discipline: discipline,
                        isHighlighted: isHighlighted(discipline),
                        action: { toggle(discipline) }
                    )
                }
            }
            // Aligns the first chip with the searchable field's leading edge.
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    private func isHighlighted(_ discipline: Discipline) -> Bool {
        selection.isEmpty || selection.contains(discipline)
    }

    private func toggle(_ discipline: Discipline) {
        withAnimation(.snappy(duration: 0.2)) {
            selection.formSymmetricDifference([discipline])
        }
    }
}

private struct DisciplineFilterButton: View {
    let discipline: Discipline
    let isHighlighted: Bool
    let action: () -> Void

    var body: some View {
        if isHighlighted {
            Button(discipline.title, systemImage: discipline.icon) {
                action()
            }
            .tint(discipline.color)
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.glassProminent)
        } else {
            Button(discipline.title, systemImage: discipline.icon) {
                action()
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.glass)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutExercisePicker(workout: Workout.samples[0])
    }
    .sampleData()
}
