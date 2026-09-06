//
//  OverviewScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct OverviewScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    @Query(Session.activeDescriptor) private var active: [Session]
    @Query(Session.finishedDescriptor) private var sessions: [Session]
    @Query(sort: \Workout.name) private var workouts: [Workout]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                SummarySection(statistics: sessions.statistics().overall)

                TodaySection(
                    state: DayState(workouts: workouts, statistics: sessions.statistics(), on: .now),
                    canStart: active.isEmpty,
                    onStart: { workout in replaceSession(workout: workout) }
                )
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
        }
        .navigationTitle(.screenOverviewTitle)
        .navigationDestination(for: Workout.self) { workout in
            WorkoutScreen(workout: workout)
        }
        .toolbar {
            Menu(.more) {

            }
        }
    }

    private func replaceSession(workout: Workout) {
        do {
            let session = try Session.start(workout, in: modelContext)

            DispatchQueue.main.async {
                presentSession(session)
            }
        } catch {
            // TODO: Log error
        }
    }
}

#Preview {
    NavigationStack {
        OverviewScreen()
    }
    .sampleData()
}
