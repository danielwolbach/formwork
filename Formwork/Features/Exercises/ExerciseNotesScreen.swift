//
//  ExerciseNotesScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 28.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ExerciseNotesScreen: View {
    @Binding
    private var notes: String

    @FocusState
    private var focused: Bool

    @State
    private var editing = false

    init(notes: Binding<String>) {
        self._notes = notes
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if editing {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) {
                            focused = false
                        }
                    }
                }
            }
            .onChange(of: focused) {
                withAnimation {
                    editing = focused
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(300))
                focused = true
            }
    }
}

#Preview {
    NavigationRoot {
        ExerciseNotesScreen(notes: .constant(Samples.exercises[1].notes))
    }
    .sampleData()
}
