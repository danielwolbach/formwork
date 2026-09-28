//
//  ExerciseGuideScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import SwiftUI

struct ExerciseGuideScreen: View {
    private let exercise: Exercise

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        ScrollView {
            ExerciseGuide(exercise)
                .padding(.horizontal)
        }
        .navigationTitle(.placeholder)
        .navigationSubtitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
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
        ExerciseGuideScreen(Samples.exercises[1])
    }
    .sampleData()
}
