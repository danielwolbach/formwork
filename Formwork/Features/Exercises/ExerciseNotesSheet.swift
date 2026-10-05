//
//  ExerciseNotesSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 28.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ExerciseNotesSheet: View {
    private let exercise: Exercise

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var notes: String

    @FocusState
    private var focused: Bool

    init(_ exercise: Exercise) {
        self._notes = .init(initialValue: exercise.notes)
        self.exercise = exercise
    }

    var body: some View {
        TextEditor(text: $notes)
            .focused($focused)
            .overlay(alignment: .topLeading) {
                if notes.isEmpty {
                    Text(.fieldNotesPlaceholder)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal)
            .navigationTitle(.fieldNotesTitle)
            .navigationSubtitle(exercise.title)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.large])
            .interactiveDismissDisabled(hasChanges)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButton(hasChanges: hasChanges)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm) {
                        exercise.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(500))
                focused = true
            }
    }

    private var hasChanges: Bool {
        notes != exercise.notes
    }
}

#Preview {
    NavigationRoot {
        ExerciseNotesSheet(Samples.exercises.first!)
    }
    .sampleData()
}
