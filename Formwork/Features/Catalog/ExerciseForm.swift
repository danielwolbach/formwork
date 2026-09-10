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
            Section(.fieldNameTitle) {
                TextField(exercise?.name ?? String(localized: .fieldNameTitle), text: $name)
            }

            Section(.fieldExerciseTypeTitle) {
                ExerciseTypePicker(type: $type)
            }

            Section(.fieldExerciseCategoriesTitle) {
                ExerciseCategoryPicker(categories: $categories)
            }
        }
        .navigationTitle(exercise == nil ? .screenExerciseCreateTitle : .screenExerciseEditTitle)
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
        TileGrid(spacing: 12) {
            ForEach(ExerciseType.allCases, id: \.self) { candidate in
                ExerciseTypeOption(type: candidate, isSelected: candidate == type) {
                    type = candidate
                }
            }
        }
        .sensoryFeedback(.selection, trigger: type)
    }
}

private struct ExerciseTypeOption: View {
    let type: ExerciseType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectableTile(
            outline: RoundedRectangle(cornerRadius: 12, style: .continuous),
            tint: type.pictogram.color,
            isSelected: isSelected,
            borderWidth: 2,
            action: action
        ) {
            VStack {
                Image(systemName: type.pictogram.icon)
                    .frame(width: 24, height: 24)

                Text(type.title)
                    .lineLimit(1)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ExerciseCategoryPicker: View {
    @Binding var categories: Set<ExerciseCategory>

    var body: some View {
        FlowLayout(spacing: 8, alignment: .center) {
            ForEach(ExerciseCategory.allCases, id: \.self) { candidate in
                ExerciseCategoryChip(category: candidate, isSelected: categories.contains(candidate)) {
                    if categories.contains(candidate) {
                        categories.remove(candidate)
                    } else {
                        categories.insert(candidate)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .sensoryFeedback(.selection, trigger: categories)
    }
}

private struct ExerciseCategoryChip: View {
    let category: ExerciseCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectableTile(
            outline: Capsule(),
            tint: category.pictogram.color,
            isSelected: isSelected,
            action: action
        ) {
            HStack(spacing: 6) {
                Image(systemName: category.pictogram.icon)
                    .font(.subheadline)

                Text(category.title)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
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
