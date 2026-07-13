//
//  WorkoutExercisePicker.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutExercisePicker: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var selectedDisciplines: Set<Discipline> = []
    @State private var searchText = ""
    @State private var createSheet = false

    let workout: Workout

    var body: some View {
        content
            .navigationTitle("Add Exercise")
            .navigationSubtitle(workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search Exercises")
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
                    ExerciseFormScreen(disciplines: selectedDisciplines.isEmpty ? nil : selectedDisciplines)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if exercises.isEmpty {
            ContentUnavailableView("No Exercises", systemImage: Exercise.systemImage)
        } else if matchingExercises.isEmpty {
            emptyState
        } else {
            ScrollView {
                ScreenStack {
                    exerciseRows
                }
            }
        }
    }

    private var exerciseRows: some View {
        RowStack {
            ForEach(matchingExercises) { exercise in
                ExercisePickerRow(exercise: exercise)
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
                "No Matching Exercises",
                systemImage: Exercise.systemImage,
                description: Text("Try different filters.")
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

private struct ExercisePickerRow: View {
    let exercise: Exercise

    var body: some View {
        NavigationLink(value: exercise) {
            NavigationRow(
                title: exercise.name,
                subtitle: exercise.disciplinesText,
                systemImage: exercise.systemImage,
                color: exercise.color
            )
        }
        .buttonStyle(.plain)
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
            .padding(.horizontal)
            // Aligns the first chip with the searchable field's leading edge.
            .padding(.horizontal)
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
            if selection.contains(discipline) {
                selection.remove(discipline)
            } else {
                selection.insert(discipline)
            }
        }
    }
}

private struct DisciplineFilterButton: View {
    let discipline: Discipline
    let isHighlighted: Bool
    let action: () -> Void

    var body: some View {
        if isHighlighted {
            LabelButton(
                discipline.title,
                systemImage: discipline.systemImage,
                style: .glassProminent
            ) {
                action()
            }
            .tint(discipline.color)
        } else {
            LabelButton(discipline.title, systemImage: discipline.systemImage) {
                action()
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutExercisePicker(workout: Workout.samples[0])
    }
    .sampleData()
}
