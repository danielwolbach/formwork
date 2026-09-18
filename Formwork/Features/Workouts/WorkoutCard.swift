//
//  WorkoutCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct WorkoutCard: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: workout.pictogram.image)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(workout.pictogram.color)
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background(workout.pictogram.color.quaternary)

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

                FlowLayout(alignment: .leading) {
                    ForEach(categories) { category in
                        Label(category.title, systemImage: category.pictogram.image)
                            .labelStyle(.chip(tint: category.pictogram.color))
                    }
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .contentShape(.rect)
    }

    private var categories: [ExerciseCategory] {
        let present = Set(workout.entries.compactMap(\.exercise).flatMap(\.categories))
        return ExerciseCategory.allCases.filter(present.contains)
    }
}

#Preview {
    WorkoutCard(workout: Samples.workouts.first!)
        .padding()
}
