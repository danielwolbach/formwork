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
    private let title: String

    @Binding
    private var original: String

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var notes: String

    @FocusState
    private var focused: Bool

    init(notes: Binding<String>, title: String) {
        self.title = title
        self._original = notes
        self._notes = .init(initialValue: notes.wrappedValue)
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
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal)
            .navigationTitle(.fieldNotesTitle)
            .navigationSubtitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.large])
            .interactiveDismissDisabled(hasChanges)
            .accessibilityLabel(Text(.fieldNotesTitle))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButton(hasChanges: hasChanges)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm) {
                        original = notes.trimmingCharacters(in: .whitespacesAndNewlines)
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
        notes != original
    }
}

#Preview {
    NavigationRoot {
        ExerciseNotesSheet(notes: .constant(Samples.exercises[1].notes), title: Samples.exercises[1].title)
    }
    .sampleData()
}
