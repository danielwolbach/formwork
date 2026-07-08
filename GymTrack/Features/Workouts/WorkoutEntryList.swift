//
//  WorkoutEntryList.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct WorkoutEntryList: View {
    let entries: [WorkoutEntry]

    var body: some View {
        if entries.isEmpty {
            ContentUnavailableView("No Exercises", systemImage: Exercise.systemImage)
        } else {
            RowStack {
                ForEach(entries) { entry in
                    NavigationLink(value: entry) {
                        NavigationRow(
                            title: entry.exercise.name,
                            subtitle: entry.target.description,
                            systemImage: entry.exercise.systemImage,
                            color: entry.exercise.color
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview("Samples") {
    NavigationStack {
        WorkoutEntryList(entries: WorkoutEntry.samples)
    }
}

#Preview("Empty") {
    NavigationStack {
        WorkoutEntryList(entries: [])
    }
}
