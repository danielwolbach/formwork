//
//  TodaySection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

/// The day's heading, its start button, and whatever is left to do under it.
///
/// Takes its state rather than deriving it, so every branch is reachable from a
/// preview without arranging sample history to match.
struct TodaySection: View {
    let state: DayState

    var date: Date = .now

    /// `false` while a session is already running — starting another one would
    /// replace it.
    var canStart: Bool = true

    var onStart: (Workout) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(verbatim: date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(.overviewTodayTitle)
                        .font(.headline)
                }

                Spacer()

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

            switch state {
            case let .remaining(workouts):
                LazyVStack {
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
        }
    }
}

private struct TodaySectionPreview: View {
    let state: DayState
    var canStart: Bool = true

    var body: some View {
        NavigationStack {
            ScrollView {
                TodaySection(state: state, canStart: canStart)
                    .padding(.horizontal)
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
