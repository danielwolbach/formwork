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
        RowStack {
            ForEach(exercises) { exercise in
                IconNavigationRow(
                    value: exercise,
                    icon: exercise.icon,
                    color: exercise.color,
                    title: exercise.title,
                    subtitle: exercise.subtitle
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseList(exercises: Exercise.samples)
    }
}
