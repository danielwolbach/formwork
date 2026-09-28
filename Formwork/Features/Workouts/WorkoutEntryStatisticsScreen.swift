//
//  WorkoutEntryStatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import SwiftUI

struct WorkoutEntryStatisticsScreen: View {
    private enum ViewMode: Hashable {
        case entry, exercise
    }

    let entry: WorkoutEntry

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var viewMode: ViewMode = .entry

    init(_ entry: WorkoutEntry) {
        self.entry = entry
    }

    var body: some View {
        ScrollView {
            ZStack {
                ExerciseStatistics(history: history)
                    .padding(.horizontal)
                    .id(viewMode)
                    .transition(.blurReplace)
            }
            .animation(.smooth, value: viewMode)
        }
        .navigationTitle(.screenStatisticsTitle)
        .navigationSubtitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }

            if isDoneElsewhere {
                ToolbarItem {
                    // TODO: Add `Action` entry.
                    Menu {
                        Picker(selection: $viewMode) {
                            Text(.placeholder)
                                .tag(ViewMode.entry)

                            Text(.placeholder)
                                .tag(ViewMode.exercise)
                        } label: {
                            Label(String(localized: .placeholder), systemImage: "calendar.day.timeline.left")
                        }
                    } label: {
                        Label(String(localized: .placeholder), systemImage: "calendar.day.timeline.left")
                    }
                }
            }
        }
    }

    private var history: History {
        if viewMode == .exercise, let exercise = entry.exercise {
            History(.exercise(exercise))
        } else {
            History(.entry(entry))
        }
    }

    private var isDoneElsewhere: Bool {
        entry.exercise?.sessionEntries.contains { $0.workoutEntry !== entry && $0.session.map { !$0.isActive } ?? false } ?? false
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryStatisticsScreen(Samples.workouts[0].entries.sorted()[1])
    }
    .sampleData()
}
