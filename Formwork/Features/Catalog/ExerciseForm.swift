//
//  ExerciseForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct ExerciseForm: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var name: String
    @State private var type: ExerciseType
    @State private var categories: Set<ExerciseCategory>

    let exercise: Exercise?

    init(exercise: Exercise? = nil) {
        self._name = State(initialValue: exercise?.name ?? "")
        self._type = State(initialValue: exercise?.type ?? .weight)
        self._categories = State(initialValue: exercise?.categories ?? [])
        self.exercise = exercise
    }

    init(category: ExerciseCategory) {
        self._name = State(initialValue: "")
        self._type = State(initialValue: .weight)
        self._categories = State(initialValue: [category])
        self.exercise = nil
    }

    var body: some View {
        Form {
            Section(.sectionExerciseNameTitle) {
                TextField(exercise?.name ?? "", text: $name)
            }

            Section(.sectionExerciseTypeTitle) {
                ExerciseTypePicker(type: $type)
            }

            Section(.sectionExerciseCategoriesTitle) {
                ExerciseCategoryPicker(categories: $categories)
            }
        }
        .navigationTitle(exercise == nil ? .screenExerciseCreateTitle : .screenExerciseEditTitle)
        .navigationBarTitleDisplayMode(.inline)
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

    private var valid: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }

    private func save() {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let categories = categories.isEmpty ? [.other] : categories

        if let exercise {
            exercise.name = name
            exercise.type = type
            exercise.categories = categories
        } else {
            let exercise = Exercise(name: name, type: type, categories: categories)
            modelContext.insert(exercise)
        }

        dismiss()
    }
}

private struct ExerciseTypePicker: View {
    @Binding var type: ExerciseType

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(ExerciseType.allCases) { candidate in
                Toggle(isOn: binding(for: candidate)) {
                    VStack {
                        Image(systemName: candidate.pictogram.image)
                            .frame(width: 24, height: 24)

                        Text(candidate.title)
                            .lineLimit(1)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .toggleStyle(.card(tint: candidate.pictogram.color))
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .sensoryFeedback(.selection, trigger: type)
    }

    private func binding(for candidate: ExerciseType) -> Binding<Bool> {
        Binding(
            get: { type == candidate },
            set: { selected in
                if selected {
                    type = candidate
                }
            }
        )
    }
}

private struct ExerciseCategoryPicker: View {
    @Binding var categories: Set<ExerciseCategory>

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(ExerciseCategory.allCases, id: \.self) { candidate in
                Toggle(candidate.title, systemImage: candidate.pictogram.image, isOn: binding(for: candidate))
                    .font(.subheadline)
                    .lineLimit(1)
                    .toggleStyle(.card(tint: candidate.pictogram.color))
                    .labelStyle(.fixedTitleAndIcon)
            }
        }
        .buttonBorderShape(.capsule)
        .sensoryFeedback(.selection, trigger: categories)
    }

    private func binding(for candidate: ExerciseCategory) -> Binding<Bool> {
        Binding(
            get: { categories.contains(candidate) },
            set: { selected in
                if selected {
                    categories.insert(candidate)
                } else {
                    categories.remove(candidate)
                }
            }
        )
    }
}

#Preview("Create") {
    NavigationStack {
        ExerciseForm()
    }
}

#Preview("Edit") {
    NavigationStack {
        ExerciseForm(exercise: Samples.exercises.first!)
    }
}
