//
//  WorkoutIndexScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutIndexScreen: View {
    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(filter: #Predicate<Workout> { !$0.isArchived }, sort: \Workout.name)
    private var workouts: [Workout]

    @State
    private var sheet: Sheet? = nil

    var body: some View {
        Group {
            if workouts.isEmpty {
                emptyState
            } else {
                ScrollView {
                    ContentStack {
                        LazyVStack(spacing: .items) {
                            ForEach(workouts) { workout in
                                WorkoutCard(workout)
                            }
                        }
                        .swipeActionsContainer()
                        .animation(.snappy, value: workouts.count)
                    }
                }
                .contentMargins(.bottom, .sections, for: .scrollContent)
            }
        }
        .navigationTitle(.screenWorkoutsTitle)
        .navigationDestination(for: Workout.self) { workout in
            WorkoutScreen(workout)
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.createWorkout) {
                        if fullVersion.canAddWorkout(in: context) {
                            sheet = .createWorkout
                        } else {
                            presentPaywall()
                        }
                    }
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyWorkoutsTitle, systemImage: "clipboard")
        } description: {
            Text(.emptyWorkoutsMessage)
        } actions: {
            Button(.createWorkout) {
                sheet = .createWorkout
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutIndexScreen()
    }
    .sampleData()
}
