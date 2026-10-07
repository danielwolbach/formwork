//
//  WorkoutSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct WorkoutSheet: View {
    private let workout: Workout

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    init(_ workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        WorkoutScreen(workout)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(.cancel) {
                        dismiss()
                    }
                }
            }
    }
}

#Preview {
    NavigationRoot {
        WorkoutSheet(Samples.workouts.first!)
    }
    .sampleData()
}
