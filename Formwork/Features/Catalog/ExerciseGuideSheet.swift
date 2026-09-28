//
//  ExerciseGuideSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import SwiftUI

struct ExerciseGuideSheet: View {
    private let exercise: Exercise

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                DisplayableRow(exercise)
                    .padding(.horizontal)

                ExerciseGuide(exercise)
                    .padding(.horizontal)
            }
            .padding(.vertical, 16)
            .padding(.top, 16)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        ExerciseGuideSheet(Samples.exercises[1])
    }
    .sampleData()
}
