//
//  OverviewScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 19.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct OverviewScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    @Query(Session.activeDescriptor) private var activeSessions: [Session]
    @Query private var sessions: [Session]
    @Query private var workouts: [Workout]
    @State private var sessionActiveAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                statisticsSection
                todaySection
            }
            .padding(.horizontal)
        }
        .navigationTitle(.screenOverviewTitle)
        .navigationDestination(for: Workout.self) { workout in
            WorkoutScreen(workout: workout)
        }
        .alert(.alertSessionActiveTitle, isPresented: $sessionActiveAlert) {
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

            Button(.cancel) {}
        } message: {
            Text(.alertSessionActiveMessage)
        }
    }

    @ViewBuilder
    private var statisticsSection: some View {
        let statistics = sessions.statistics()

        LazyVGrid(columns: [.init(.flexible(), spacing: 8), .init(.flexible(), spacing: 8)], spacing: 8) {
            StatisticCard(statistics.weekStreak)
            StatisticCard(statistics.lastSession)
        }
    }

    @ViewBuilder
    private var todaySection: some View {
        let pending = workouts.pending()

        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(.sectionOverviewToday)
                        .lineLimit(1)
                        .font(.headline)

                    Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let workout = pending.first {
                    Button(.startSession) {
                        startSession(workout: workout)
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glassProminent)
                    .tint(.green)
                }
            }
            .padding(.horizontal, 2)

            if pending.isEmpty {
                if workouts.contains(where: { $0.schedule.isScheduled(on: .now) }) {
                    StateCard(
                        title: .emptyOverviewAllDoneTitle,
                        description: .emptyOverviewAllDoneDescription,
                        image: "checkmark.seal",
                        tint: .green
                    )
                } else {
                    StateCard(
                        title: .emptyOverviewRestDayTitle,
                        description: .emptyOverviewRestDayDescription,
                        image: "moon.zzz",
                        tint: .purple
                    )
                }
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(pending) { workout in
                        NavigationLink(value: workout) {
                            WorkoutCard(workout: workout)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
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
        do {
            let session = try Session.start(workout, in: modelContext)
            DispatchQueue.main.async { presentSession(session) }
        } catch {
            // TODO: Log error
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

#Preview {
    NavigationStack {
        OverviewScreen()
    }
    .sampleData()
}
