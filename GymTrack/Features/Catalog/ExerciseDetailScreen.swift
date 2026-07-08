//
//  ExerciseDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct ExerciseDetailScreen: View {
    @State private var sheet: ExerciseSheet?

    let exercise: Exercise

    var body: some View {
        ScrollView {
            ScreenStack {
                DetailHero(
                    title: exercise.name,
                    subtitle: exercise.metric.description,
                    systemImage: exercise.systemImage,
                    color: exercise.color
                )

                // TODO:
            }
        }
        .toolbar {
            Menu(.moreOptions) {
                Section {
                    Button(.edit) {
                        sheet = .editExercise(exercise)
                    }
                }

                Section {
                    Button(.delete) {}
                }
            }
        }
        .exerciseSheet(item: $sheet)
    }
}
