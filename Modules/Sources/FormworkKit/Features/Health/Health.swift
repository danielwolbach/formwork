//
//  Health.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 06.10.26.
//

import HealthKit
import OSLog

@MainActor
@Observable
public final class Health: NSObject {
    public enum Status {
        case unavailable, disconnected, connected, denied
    }

    public static let shared = Health()

    static let store = HKHealthStore()

    private static let sharedTypes: Set<HKSampleType> = [.workoutType(), HKQuantityType(.bodyMass)]

    private static let readTypes: Set<HKSampleType> = [HKQuantityType(.activeEnergyBurned), HKQuantityType(.heartRate), HKQuantityType(.bodyMass)]

    public private(set) var heartRate: Double?

    public private(set) var activeEnergy: Double?

    @ObservationIgnored
    private var live: HKWorkoutSession?

    @ObservationIgnored
    private var builder: HKLiveWorkoutBuilder?

    @ObservationIgnored
    private var tracked: Session?

    @ObservationIgnored
    private var hasRecovered = false

    @ObservationIgnored
    private var pending: Task<Void, Never>?
}

extension Health {
    public static var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    static var isAuthorized: Bool {
        isAvailable && store.authorizationStatus(for: .workoutType()) == .sharingAuthorized
    }

    public static func status() async -> Status {
        guard isAvailable else {
            return .unavailable
        }

        guard await (try? store.statusForAuthorizationRequest(toShare: sharedTypes, read: readTypes)) == .unnecessary else {
            return .disconnected
        }

        return isAuthorized ? .connected : .denied
    }

    public static func connect() async throws {
        try await store.requestAuthorization(toShare: sharedTypes, read: readTypes)
    }

    public static func delete(_ session: Session) {
        guard isAuthorized, let endDate = session.endDate else {
            return
        }

        let startDate = session.startDate

        Task {
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            _ = try? await store.deleteObjects(of: .workoutType(), predicate: predicate)
        }
    }
}

extension Health {
    private nonisolated static func statistics(of builder: HKLiveWorkoutBuilder) -> (heartRate: Double?, activeEnergy: Double?) {
        let heartRate = builder.statistics(for: HKQuantityType(.heartRate))?
            .mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute()))
        let activeEnergy = builder.statistics(for: HKQuantityType(.activeEnergyBurned))?
            .sumQuantity()?.doubleValue(for: .kilocalorie())

        return (heartRate, activeEnergy)
    }

    public func sync(_ session: Session?) async {
        let previous = pending
        let task = Task {
            await previous?.value
            await apply(session)
        }
        pending = task
        await task.value
    }

    private func apply(_ session: Session?) async {
        if !hasRecovered {
            hasRecovered = true

            do {
                if let recovered = try await Self.store.recoverActiveWorkoutSession() {
                    Logger.health.info("Recovered workout session in state \(recovered.state.rawValue)")

                    // The data source lived in the previous process, so the recovered builder has none.
                    let builder = recovered.associatedWorkoutBuilder()
                    builder.dataSource = HKLiveWorkoutDataSource(healthStore: Self.store, workoutConfiguration: recovered.workoutConfiguration)

                    attach(recovered, builder: builder, for: session)
                    update(from: Self.statistics(of: builder))
                } else {
                    Logger.health.info("No workout session to recover")
                }
            } catch {
                Logger.health.error("Recovering workout session failed: \(error, privacy: .public)")
            }
        }

        let running = session?.endDate == nil ? session : nil

        // Also ends when the session was replaced, since the new one needs its own workout.
        if live != nil, running == nil || running !== tracked {
            if let tracked, isFinished(tracked) {
                await finish(tracked)
            } else {
                discard()
            }
        }

        if let running, live == nil, Self.isAuthorized {
            await start(for: running)
        }
    }

    private func start(for session: Session) async {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .crossTraining

        do {
            let live = try HKWorkoutSession(healthStore: Self.store, configuration: configuration)
            let builder = live.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: Self.store, workoutConfiguration: configuration)

            attach(live, builder: builder, for: session)

            live.startActivity(with: session.startDate)
            try await builder.beginCollection(at: session.startDate)

            Logger.health.info("Started workout session")
        } catch {
            Logger.health.error("Starting workout session failed: \(error, privacy: .public)")
            discard()
        }
    }

    private func finish(_ session: Session) async {
        guard let live, let builder else {
            return
        }

        reset()
        live.end()

        do {
            try await builder.endCollection(at: session.endDate ?? .now)

            session.health = Session.HealthSummary(
                averageHeartRate: builder.statistics(for: HKQuantityType(.heartRate))?
                    .averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())),
                activeEnergy: builder.statistics(for: HKQuantityType(.activeEnergyBurned))?
                    .sumQuantity()?.doubleValue(for: .kilocalorie())
            )

            _ = try await builder.finishWorkout()

            Logger.health.info("Finished workout session")
        } catch {
            Logger.health.error("Finishing workout session failed: \(error, privacy: .public)")
            builder.discardWorkout()
        }
    }

    private func discard() {
        guard let live, let builder else {
            return
        }

        reset()
        live.end()
        builder.discardWorkout()

        Logger.health.info("Discarded workout session")
    }

    private func attach(_ live: HKWorkoutSession, builder: HKLiveWorkoutBuilder, for session: Session?) {
        live.delegate = self
        builder.delegate = self

        self.live = live
        self.builder = builder
        tracked = session
    }

    private func update(from statistics: (heartRate: Double?, activeEnergy: Double?)) {
        heartRate = statistics.heartRate ?? heartRate
        activeEnergy = statistics.activeEnergy ?? activeEnergy
    }

    private func reset() {
        live = nil
        builder = nil
        tracked = nil
        heartRate = nil
        activeEnergy = nil
    }

    private func isFinished(_ session: Session) -> Bool {
        !session.isDeleted && session.modelContext != nil && session.endDate != nil
            && session.entries.contains(where: \.status.isCompleted)
    }
}

extension Health: HKWorkoutSessionDelegate {
    public nonisolated func workoutSession(_: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date _: Date) {
        Logger.health.info("Workout session changed from state \(fromState.rawValue) to \(toState.rawValue)")
    }

    public nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        Logger.health.error("Workout session failed: \(error, privacy: .public)")

        let id = ObjectIdentifier(workoutSession)

        Task { @MainActor in
            guard let live, ObjectIdentifier(live) == id else {
                return
            }

            discard()
        }
    }
}

extension Health: HKLiveWorkoutBuilderDelegate {
    public nonisolated func workoutBuilderDidCollectEvent(_: HKLiveWorkoutBuilder) {}

    public nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf _: Set<HKSampleType>) {
        let id = ObjectIdentifier(workoutBuilder)
        let statistics = Self.statistics(of: workoutBuilder)

        Task { @MainActor in
            guard let builder, ObjectIdentifier(builder) == id else {
                return
            }

            update(from: statistics)
        }
    }
}
