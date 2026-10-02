//
//  WorkoutEntryStatisticsSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutEntryStatisticsSheet: View {
    private enum ViewMode: Hashable {
        case workout, overall
    }

    let entry: WorkoutEntry

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    @State
    private var viewMode: ViewMode

    init(_ entry: WorkoutEntry) {
        self.entry = entry
        self._viewMode = .init(initialValue: entry.workout == nil ? .overall : .workout)
    }

    var body: some View {
        Group {
            if history.sessions.isEmpty {
                ContentUnavailableView {
                    Label(.emptyStatisticsTitle, systemImage: "flame")
                } description: {
                    Text(.emptyStatisticsMessage)
                }
            } else {
                ScrollView {
                    ContentStack {
                        ZStack {
                            StatisticGrid(history)
                                .id(viewMode)
                                .transition(.blurReplace)
                        }
                        .animation(.smooth, value: viewMode)
                    }
                }
                .contentMargins(.bottom, .sections, for: .scrollContent)
            }
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

            if isDoneElsewhere, let workout = entry.workout {
                ToolbarItem {
                    Menu(.viewMode) {
                        Picker(.fieldViewModeTitle, selection: $viewMode) {
                            Text(workout.title)
                                .tag(ViewMode.workout)

                            Text(.fieldOverallTitle)
                                .tag(ViewMode.overall)
                        }
                    }
                }
            }
        }
    }

    private var history: History {
        if viewMode == .overall, let exercise = entry.exercise {
            History(.exercise(exercise), among: sessions)
        } else {
            History(.entry(entry), among: sessions)
        }
    }

    private var isDoneElsewhere: Bool {
        entry.exercise?.sessionEntries.contains { $0.workoutEntry !== entry && $0.session.map { !$0.isActive } ?? false } ?? false
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryStatisticsSheet(Samples.workouts[0].entries.sorted()[1])
    }
    .sampleData()
}
