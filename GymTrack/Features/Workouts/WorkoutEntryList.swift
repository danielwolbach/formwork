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
        RowStack {
            ForEach(entries) { entry in
                IconNavigationRow(
                    value: entry,
                    icon: entry.icon,
                    color: entry.color,
                    title: entry.title,
                    subtitle: entry.subtitle
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryList(entries: WorkoutEntry.samples)
    }
}
