//
//  ExerciseList.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct ExerciseList: View {
    let exercises: [Exercise]

    var body: some View {
        if exercises.isEmpty {
            ContentUnavailableView("No Exercises", systemImage: Exercise.systemImage)
        } else {
            ScrollView {
                ScreenStack {
                    RowStack {
                        ForEach(exercises) { exercise in
                            NavigationLink(value: exercise) {
                                NavigationRow(
                                    title: exercise.name,
                                    subtitle: exercise.metric.description,
                                    systemImage: exercise.systemImage,
                                    color: exercise.color
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

#Preview("Samples") {
    NavigationStack {
        ExerciseList(exercises: Exercise.samples)
    }
}

#Preview("Empty") {
    NavigationStack {
        ExerciseList(exercises: [])
    }
}
