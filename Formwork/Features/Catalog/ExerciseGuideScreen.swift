//
//  ExerciseGuideScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import SwiftUI

/// An exercise's guide on its own, for screens without room to show it inline. Only ever presented as a sheet, so it
/// owns its close button.
struct ExerciseGuideScreen: View {
    let exercise: Exercise

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    var body: some View {
        ScrollView {
            ExerciseGuide(exercise: exercise)
        }
        .navigationTitle(.screenExerciseGuideTitle)
        .navigationSubtitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .presentationDetents([.medium, .large])
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .close) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseGuideScreen(exercise: Samples.exercises.first!)
    }
    .sampleData()
}
