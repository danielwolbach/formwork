//
//  ExerciseGuideSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ExerciseGuideSheet: View {
    private let exercise: Exercise

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        ScrollView {
            ContentStack(spacing: .groups) {
                PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))

                ExerciseGuide(exercise)
            }
        }
        .contentMargins(.vertical, .sections, for: .scrollContent)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationRoot {
        ExerciseGuideSheet(Samples.exercises[1])
    }
    .sampleData()
}
