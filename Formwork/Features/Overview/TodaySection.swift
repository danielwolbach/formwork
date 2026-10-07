//
//  TodaySection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct TodaySection: View {
    @Environment(\.startSession)
    private var startSession: StartSessionAction

    @Query(filter: #Predicate<Workout> { !$0.isArchived })
    private var workouts: [Workout]

    var body: some View {
        let pending = workouts.pending()

        SectionView(.fieldTodayTitle, subtitle: Date.now.formatted(date: .abbreviated, time: .omitted)) {
            if pending.isEmpty {
                if workouts.contains(where: { $0.isScheduled() }) {
                    StateCard(
                        title: .emptyAllDoneTitle,
                        description: .emptyAllDoneMessage,
                        image: "checkmark.seal.fill",
                        tint: .green
                    )
                } else {
                    StateCard(
                        title: .emptyRestDayTitle,
                        description: .emptyRestDayMessage,
                        image: "moon.zzz.fill",
                        tint: .purple
                    )
                }
            } else {
                VStack(spacing: .items) {
                    ForEach(pending) { workout in
                        WorkoutCard(workout)
                    }
                }
                .swipeActionsContainer()
                .edgeToEdge()
            }
        } accessory: {
            if let workout = pending.first {
                Button(.startSession) {
                    startSession(workout)
                }
                .labelStyle(.fixedTitleAndIcon)
                .buttonStyle(.glassProminent)
                .tint(.green)
                .disabled(!workout.isStartable)
            }
        }
    }
}

private struct StateCard: View {
    let title: LocalizedStringResource

    let description: LocalizedStringResource

    let image: String

    let tint: Color

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: image)
                .font(.system(size: 48))
                .foregroundStyle(tint)
                .accessibilityHidden(true)

            VStack {
                Text(title)
                    .lineLimit(1)
                    .font(.headline)

                Text(description)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1.8, contentMode: .fit)
        .background(tint.quinary, in: .rect(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
