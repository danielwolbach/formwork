//
//  WorkoutEntryDetail.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct WorkoutEntryDetailScreen: View {
    let entry: WorkoutEntry
    
    var body: some View {
        ScrollView {
            ScreenStack {
                DetailHero(
                    title: entry.exercise.name,
                    subtitle: entry.exercise.metric.description,
                    systemImage: entry.exercise.systemImage,
                    color: entry.exercise.color
                )
                
                // TODO
            }
        }
        .toolbar {
            Menu(.moreOptions) {
                Section {
                    Menu(.metric) {
                        Picker(ActionDescriptor.metric.title, selection: .constant(ExerciseMetric.weight)) { // TODO
                            ForEach(ExerciseMetric.allCases) { metric in
                                Label(metric.description, systemImage: metric.systemImage)
                            }
                        }
                    }
                }
                
                Section {
                    Button(.remove) {
                        // TODO
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryDetailScreen(entry: WorkoutEntry.samples[0])
    }
}
