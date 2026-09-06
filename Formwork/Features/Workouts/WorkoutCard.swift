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
            banner
            content
        }
        .background(.background)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 4)
        .contentShape(.rect)
    }

    private var banner: some View {
        Image(systemName: workout.pictogram.icon)
            .font(.system(size: 32, weight: .medium))
            .foregroundStyle(workout.pictogram.color)
            .frame(maxWidth: .infinity)
            .frame(height: 96)
            .background(workout.pictogram.color.quaternary)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text(workout.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(workout.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if !categories.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(categories, id: \.self) { category in
                        CategoryChip(category: category)
                    }
                }
            }
        }
        .padding()
    }
    
    private var categories: [ExerciseCategory] {
        let present = Set(workout.entries.compactMap(\.exercise).flatMap(\.categories))
        return ExerciseCategory.allCases.filter(present.contains)
    }
}

private struct CategoryChip: View {
    let category: ExerciseCategory

    private var tint: Color {
        category.pictogram.color
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.pictogram.icon)
                .font(.caption)

            Text(category.title)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(tint)
        .background {
            Capsule().fill(tint.quinary)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Samples.workouts) { workout in
                    NavigationLink(value: workout) {
                        WorkoutCard(workout: workout)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    .sampleData()
}
