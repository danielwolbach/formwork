//
//  OverviewScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 19.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct OverviewScreen: View {
    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Environment(\.presentSession)
    private var presentSession: PresentSessionAction

    @Query(Session.activeDescriptor)
    private var activeSessions: [Session]

    @Query
    private var sessions: [Session]

    @Query
    private var workouts: [Workout]

    @State
    private var sheet: Sheet? = nil

    @State
    private var sessionActiveAlert: Bool = false

    var body: some View {
        ScrollView {
            ContentStack {
                statisticsSection
                todaySection
                CalendarSection()
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .navigationTitle(.screenOverviewTitle)
        .navigationDestination(for: Workout.self) { workout in
            WorkoutScreen(workout)
        }
        .navigationDestination(for: Session.self) { session in
            SessionScreen(session)
        }
        .navigationDestination(for: Route.self) { route in
            route
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.settings) {
                        sheet = .settings
                    }
                }

                Section {
                    DebugMenu()
                }
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
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }

    @ViewBuilder
    private var statisticsSection: some View {
        let history = History(.all(sessions))

        TileGrid {
            StatisticCard(.weekStreak, of: history)

            StatisticCard(.lastCompleted, of: history)
        }
    }

    @ViewBuilder
    private var todaySection: some View {
        let pending = workouts.pending()

        SectionView(.init(localized: .fieldTodayTitle), subtitle: Date.now.formatted(date: .abbreviated, time: .omitted)) {
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
                LazyVStack(spacing: .items) {
                    ForEach(pending) { workout in
                        WorkoutCard(workout)
                    }
                }
                .swipeActionsContainer()
            }
        } accessory: {
            if let workout = pending.first {
                Button(.startSession) {
                    startSession(workout: workout)
                }
                .labelStyle(.fixedTitleAndIcon)
                .buttonStyle(.glassProminent)
                .tint(.green)
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

#Preview {
    NavigationStack {
        OverviewScreen()
    }
    .sampleData()
}
