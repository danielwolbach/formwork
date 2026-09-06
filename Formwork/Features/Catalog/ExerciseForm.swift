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
            ForEach(ExerciseType.allCases, id: \.self) { candidate in
                ExerciseTypeOption(type: candidate, selected: candidate == type) {
                    type = candidate
                }
            }
        }
        .sensoryFeedback(.selection, trigger: type)
    }
}

private struct ExerciseTypeOption: View {
    let type: ExerciseType
    let selected: Bool
    let action: () -> Void
    
    private var tint: Color {
        selected ? type.pictogram.color : .secondary
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: type.pictogram.icon)
                    .frame(width: 24, height: 24)
                
                Text(type.title)
                    .lineLimit(1)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundStyle(tint)
            .background {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    
                    Rectangle().fill(tint.quinary)
                        .opacity(selected ? 1 : 0)
                }
            }
            .contentShape(.rect)
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(tint.secondary, lineWidth: selected ? 2 : 0)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ExerciseCategoryPicker: View {
    @Binding var categories: Set<ExerciseCategory>
    
    var body: some View {
        FlowLayout(spacing: 8, alignment: .center) {
            ForEach(ExerciseCategory.allCases, id: \.self) { candidate in
                ExerciseCategoryChip(category: candidate, selected: categories.contains(candidate)) {
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
    let selected: Bool
    let action: () -> Void
    
    private var tint: Color {
        selected ? category.pictogram.color : .secondary
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.pictogram.icon)
                    .font(.subheadline)
                
                Text(category.title)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(tint)
            .background {
                ZStack {
                    Capsule().fill(.ultraThinMaterial)
                    
                    Capsule().fill(tint.quinary)
                        .opacity(selected ? 1 : 0)
                }
            }
            .contentShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(tint.secondary, lineWidth: selected ? 1.5 : 0)
            }
        }
        .buttonStyle(.plain)
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
