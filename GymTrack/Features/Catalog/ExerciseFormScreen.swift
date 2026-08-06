//
//  ExerciseFormScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct ExerciseFormScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var name: String
    @State private var type: ExerciseType
    @State private var disciplines: Set<Discipline>

    let exercise: Exercise?

    init(exercise: Exercise? = nil) {
        _name = State(initialValue: exercise?.name ?? "")
        _type = State(initialValue: exercise?.type ?? .weight)
        _disciplines = State(initialValue: exercise?.disciplines ?? [])
        self.exercise = exercise
    }

    init(name: String? = nil, type: ExerciseType? = nil, disciplines: Set<Discipline> = []) {
        _name = State(initialValue: name ?? "")
        _type = State(initialValue: type ?? .weight)
        _disciplines = State(initialValue: disciplines)
        exercise = nil
    }

    var body: some View {
        Form {
            Section(.sectionName) {
                TextField(.placeholderExerciseName, text: $name)
            }

            Section(.sectionExerciseType) {
                ExerciseTypePicker(selection: $type)
                    .disabled(!canChangeType)
            }

            Section(.sectionDisciplines) {
                ForEach(Discipline.allCases) { discipline in
                    Toggle(isOn: selected(discipline)) {
                        Label(discipline.title, systemImage: discipline.icon)
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

    private var title: LocalizedStringResource {
        exercise == nil ? .screenCreateExercise : .screenEditExercise
    }

    private var valid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !disciplines.isEmpty
    }

    private var canChangeType: Bool {
        guard let exercise else {
            return true
        }

        return exercise.workoutEntries.isEmpty && exercise.sessionEntries.isEmpty
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
            exercise.type = type
            exercise.disciplines = disciplines
        } else {
            let exercise = Exercise(name: name, type: type, disciplines: disciplines)
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
