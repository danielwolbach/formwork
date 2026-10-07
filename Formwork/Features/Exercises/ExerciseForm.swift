//
//  ExerciseForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Flow
import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct ExerciseForm: View {
    private struct Draft: Equatable {
        var name: String = ""
        var kind: Exercise.Kind = .weight
        var categories: Set<Exercise.Category> = []
        var link: String = ""
        var notes: String = ""
    }

    private let exercise: Exercise?

    private let original: Draft

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var draft: Draft

    @State
    private var showNotesEditor: Bool = false

    init(_ exercise: Exercise? = nil) {
        let draft = Draft(
            name: exercise?.name ?? "",
            kind: exercise?.kind ?? .weight,
            categories: exercise?.categories ?? [],
            link: exercise?.link?.absoluteString ?? "",
            notes: exercise?.notes ?? ""
        )

        self.exercise = exercise
        self.original = draft
        self._draft = .init(initialValue: draft)
    }

    init(categories: Set<Exercise.Category>) {
        let draft = Draft(categories: categories)

        self.exercise = nil
        self.original = draft
        self._draft = .init(initialValue: draft)
    }

    var body: some View {
        ScrollView {
            ContentStack {
                SectionView(.fieldNameTitle) {
                    GroupBox {
                        TextField(.fieldNamePlaceholder, text: $draft.name)
                    }
                }

                SectionView(.fieldKindTitle) {
                    GroupBox {
                        ExerciseKindPicker(kind: $draft.kind)
                    }
                }

                SectionView(.fieldCategoryTitle) {
                    GroupBox {
                        ExerciseCategoryPicker(categories: $draft.categories)
                    }
                }

                SectionView(.fieldLinkTitle) {
                    GroupBox {
                        LinkField(.fieldLinkPlaceholder, text: $draft.link)
                    }
                }

                SectionView(.fieldNotesTitle) {
                    Button {
                        showNotesEditor = true
                    } label: {
                        GroupBox {
                            Text(draft.notes.isEmpty ? String(localized: .fieldNotesPlaceholder) : draft.notes)
                                .foregroundStyle(draft.notes.isEmpty ? .tertiary : .primary)
                                .lineLimit(4...)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .groupBoxStyle(.card)
        .navigationTitle(exercise == nil ? .screenCreateExerciseTitle : .screenEditExerciseTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .interactiveDismissDisabled(hasChanges)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton(hasChanges: hasChanges)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    commit()
                }
                .disabled(!valid)
            }
        }
        .sheet(isPresented: $showNotesEditor) {
            NavigationRoot {
                ExerciseNotesSheet(notes: $draft.notes, title: draft.name)
            }
        }
    }

    private var hasChanges: Bool {
        draft != original
    }

    private var valid: Bool {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let link = draft.link.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty && (link.isEmpty || url != nil)
    }

    private var url: URL? {
        let link = draft.link.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = URL(string: link.contains("://") ? link : "https://\(link)")
        return url?.host() == nil ? nil : url
    }

    private func commit() {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let categories = draft.categories.isEmpty ? [.other] : draft.categories
        let notes = draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let exercise {
            exercise.name = name
            exercise.kind = draft.kind
            exercise.categories = categories
            exercise.link = url
            exercise.notes = notes
        } else {
            let exercise = Exercise(name: name, kind: draft.kind, categories: categories, link: url, notes: notes)
            context.insert(exercise)
        }

        dismiss()
    }
}

private struct ExerciseKindPicker: View {
    @Binding
    private var kind: Exercise.Kind

    init(kind: Binding<Exercise.Kind>) {
        self._kind = kind
    }

    var body: some View {
        TileGrid {
            ForEach(Exercise.Kind.allCases) { candidate in
                Button {
                    kind = candidate
                } label: {
                    VStack {
                        Image(systemName: candidate.pictogram.image)
                            .frame(width: 24, height: 24)
                            .fontWeight(.medium)

                        Text(candidate.title)
                            .lineLimit(1)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CardButtonStyle(style: kind == candidate ? .selected : .bordered))
                .tint(candidate.pictogram.color)
                .accessibilityAddTraits(kind == candidate ? [.isSelected] : [])
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .sensoryFeedback(.selection, trigger: kind)
    }
}

private struct ExerciseCategoryPicker: View {
    @Binding
    private var categories: Set<Exercise.Category>

    init(categories: Binding<Set<Exercise.Category>>) {
        self._categories = categories
    }

    var body: some View {
        HFlow(horizontalAlignment: .center, verticalAlignment: .top) {
            ForEach(Exercise.Category.allCases) { candidate in
                Button(candidate.title, systemImage: candidate.pictogram.image) {
                    categories.formSymmetricDifference([candidate])
                }
                .font(.subheadline)
                .lineLimit(1)
                .buttonStyle(CardButtonStyle(style: categories.contains(candidate) ? .selected : .bordered))
                .tint(candidate.pictogram.color)
                .labelStyle(.fixedTitleAndIcon)
                .accessibilityAddTraits(categories.contains(candidate) ? [.isSelected] : [])
            }
        }
        .frame(maxWidth: .infinity)
        .buttonBorderShape(.capsule)
        .sensoryFeedback(.selection, trigger: categories)
    }
}

#Preview("Create") {
    NavigationRoot {
        ExerciseForm()
    }
}

#Preview("Edit") {
    NavigationRoot {
        ExerciseForm(Samples.exercises.first!)
    }
}
