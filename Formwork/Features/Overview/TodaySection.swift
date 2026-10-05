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
    @Query(filter: #Predicate<Workout> { !$0.isArchived })
    private var workouts: [Workout]

    @Environment(\.presentSession)
    private var presentSession: PresentSessionAction

    @Query(Session.activeDescriptor)
    private var activeSessions: [Session]

    @State
    private var sessionActiveAlert: Bool = false

    var body: some View {
        let pending = workouts.pending()

        SectionView(.fieldTodayTitle, subtitle: Date.now.formatted(date: .abbreviated, time: .omitted)) {
            if pending.isEmpty {
                if workouts.contains(where: { $0.schedule.isScheduled(on: .now) }) {
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
                    startSession(workout: workout)
                }
                .labelStyle(.fixedTitleAndIcon)
                .buttonStyle(.glassProminent)
                .tint(.green)
                .disabled(!workout.isStartable)
            }
        }
        .alert(.alertReplaceSessionTitle, isPresented: $sessionActiveAlert) {
            if let workout = workouts.pending().first {
                Button(.replaceSession) {
                    replaceSession(workout: workout)
                }
            }

            if let activeSession = activeSessions.first {
                Button(.resumeSession) {
                    presentSession(activeSession)
                }
            }

            Button(.cancel) {
                // Works automatically.
            }
        } message: {
            Text(.alertReplaceSessionMessage)
        }
    }

    private func startSession(workout: Workout) {
        guard activeSessions.first == nil else {
            sessionActiveAlert = true
            return
        }

        replaceSession(workout: workout)
    }

    private func replaceSession(workout: Workout) {
        if let session = workout.startSession() {
            presentSession(session)
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
        .background(tint.quinary)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}
