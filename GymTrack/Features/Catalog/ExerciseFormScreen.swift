//
//  ExerciseFormScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct ExerciseFormScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction

    @State private var name: String
    @State private var metric: ExerciseMetric
    @State private var disciplines: Set<Discipline>

    let exercise: Exercise?

    init(exercise: Exercise? = nil) {
        _name = State(initialValue: exercise?.name ?? "")
        _metric = State(initialValue: exercise?.metric ?? .weight)
        _disciplines = State(initialValue: exercise?.disciplines ?? [])
        self.exercise = exercise
    }

    init(name: String? = nil, metric: ExerciseMetric? = nil, disciplines: Set<Discipline>? = nil) {
        _name = State(initialValue: name ?? "")
        _metric = State(initialValue: metric ?? .weight)
        _disciplines = State(initialValue: disciplines ?? [])
        exercise = nil
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Bench Press", text: $name)
            }

            Section("Metric") {
                Picker("Metric", selection: $metric) {
                    ForEach(ExerciseMetric.allCases) { metric in
                        Label(metric.title, systemImage: metric.systemImage)
                            .tag(metric)
                    }
                }
            }

            Section("Disciplines") {
                ForEach(Discipline.allCases) { discipline in
                    Toggle(isOn: selected(discipline)) {
                        Label(discipline.title, systemImage: discipline.systemImage)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    save()
                }
                .disabled(!valid)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
    }

    private var title: LocalizedStringKey {
        exercise == nil ? "Create Exercise" : "Edit Exercise"
    }

    private var valid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !disciplines.isEmpty
    }

    private func selected(_ discipline: Discipline) -> Binding<Bool> {
        Binding {
            disciplines.contains(discipline)
        } set: { selected in
            if selected {
                disciplines.insert(discipline)
            } else {
                disciplines.remove(discipline)
            }
        }
    }

    private func save() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let exercise {
            exercise.name = name
            exercise.metric = metric
            exercise.disciplines = disciplines
        } else {
            let exercise = Exercise(name: name, metric: metric, disciplines: disciplines)
            modelContext.insert(exercise)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            fatalError("Failed to save exercise: \(error)")
        }
    }
}

#Preview("Create") {
    NavigationStack {
        ExerciseFormScreen()
    }
}

#Preview("Edit") {
    NavigationStack {
        ExerciseFormScreen(exercise: Exercise.samples[0])
    }
}
