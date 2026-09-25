//
//  WorkoutEntryStatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import SwiftUI

struct WorkoutEntryStatisticsScreen: View {
    enum ViewMode: Hashable {
        case entry, exercise
    }

    let entry: WorkoutEntry

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var viewMode: ViewMode = .entry

    var body: some View {
        ScrollView {
            // Overlaid, so the two blur into each other rather than one below the other.
            ZStack {
                ExerciseStatistics(history: history)
                    .id(viewMode)
                    .transition(.blurReplace)
            }
        }
        .navigationTitle(.screenStatisticsTitle)
        .navigationSubtitle(subtitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }

            if isDoneElsewhere {
                ToolbarItem {
                    Menu {
                        Picker(selection: viewModeBinding) {
                            Text(.fieldStatisticsThisWorkoutTitle)
                                .tag(ViewMode.entry)

                            Text(.fieldStatisticsAllWorkoutsTitle)
                                .tag(ViewMode.exercise)
                        } label: {
                            Label(String(localized: .fieldStatisticsWorkoutsTitle), systemImage: "calendar.day.timeline.left")
                        }
                    } label: {
                        Label(String(localized: .fieldStatisticsWorkoutsTitle), systemImage: "calendar.day.timeline.left")
                    }
                }
            }
        }
    }

    var viewModeBinding: Binding<ViewMode> {
        Binding(
            get: {
                viewMode
            },
            set: { new in
                withAnimation(.smooth) {
                    viewMode = new
                }
            }
        )
    }

    private var history: History {
        if viewMode == .exercise, let exercise = entry.exercise {
            History(.exercise(exercise))
        } else {
            History(.entry(entry))
        }
    }

    private var subtitle: String {
        guard viewMode == .entry, let workout = entry.workout else {
            return entry.title
        }

        return String(localized: .screenWorkoutEntryStatisticsSubtitle(entry.title, workout.title))
    }

    private var isDoneElsewhere: Bool {
        entry.exercise?.sessionEntries.contains { $0.workoutEntry !== entry && $0.session.map { !$0.isActive } ?? false } ?? false
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryStatisticsScreen(entry: Samples.workouts[0].entries.sorted()[1])
    }
    .sampleData()
}
