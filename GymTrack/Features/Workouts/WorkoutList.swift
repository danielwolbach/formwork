//
//  WorkoutList.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct WorkoutList: View {
    let workouts: [Workout]

    var body: some View {
        RowStack {
            ForEach(workouts) { workout in
                IconNavigationRow(
                    value: workout,
                    icon: workout.icon,
                    color: workout.color,
                    title: workout.title,
                    subtitle: workout.subtitle
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutList(workouts: Workout.samples)
    }
}
