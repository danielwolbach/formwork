//
//  WorkoutCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct WorkoutCard: View {
    private let workout: Workout

    init(_ workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: workout.pictogram.image)
                .font(.system(size: 48))
                .fontWeight(.medium)
                .foregroundStyle(workout.pictogram.color)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .padding()
                .background(workout.pictogram.color.quinary)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    Text(workout.title)
                        .lineLimit(1)
                        .font(.headline)

                    if let subtitle = workout.subtitle {
                        Text(subtitle)
                            .lineLimit(1)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if !workout.exerciseCategories.isEmpty {
                    FlowLayout(alignment: .leading, rowLimit: 2) {
                        ForEach(workout.exerciseCategories) { category in
                            Label(category.title, systemImage: category.pictogram.image)
                                .labelStyle(.chip(tint: category.pictogram.color))
                        }
                    }
                }
            }
            .padding()
        }
        .card()
    }
}

#Preview {
    WorkoutCard(Samples.workouts.first!)
        .padding()
}
