//
//  TodaySection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct TodaySection: View {
    let state: DayState
    let date: Date = .now
    let canStart: Bool
    let onStart: (Workout) -> Void

    var body: some View {
        SectionStack(
            title: Text(.overviewTodayTitle),
            subtitle: Text(verbatim: date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
        ) {
            switch state {
            case let .remaining(workouts):
                TileGrid(columns: 1) {
                    ForEach(workouts) { workout in
                        NavigationLink(value: workout) {
                            WorkoutCard(workout: workout)
                        }
                        .buttonStyle(.plain)
                    }
                }

            case .finished:
                RestingView(.finished)

            case .unscheduled:
                RestingView(.unscheduled)
            }
        } accessory: {
            startButton
        }
    }

    @ViewBuilder
    private var startButton: some View {
        if let workout = state.next {
            Button(.startSession) {
                onStart(workout)
            }
            .disabled(!canStart)
            .labelStyle(.fixedTitleAndIcon)
            .tint(.green)
            .buttonStyle(.glassProminent)
        }
    }
}

private struct TodaySectionPreview: View {
    let state: DayState
    let canStart: Bool = true

    var body: some View {
        NavigationStack {
            ScreenStack {
                TodaySection(state: state, canStart: canStart, onStart: { _ in })
            }
        }
        .sampleData()
    }
}

#Preview("Remaining") {
    TodaySectionPreview(state: .remaining(Samples.workouts))
}

#Preview("Finished") {
    TodaySectionPreview(state: .finished)
}

#Preview("Rest Day") {
    TodaySectionPreview(state: .unscheduled)
}
