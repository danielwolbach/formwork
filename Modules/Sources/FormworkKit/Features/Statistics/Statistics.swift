//
//  Statistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation
import OSLog
import SwiftData

@MainActor
@Observable
public final class Statistics {
    private let container: ModelContainer?

    private var revision = 0

    @ObservationIgnored
    private var observer: ResultsObserver<Session, Never>?

    @ObservationIgnored
    private var token: ObservationTracking.Token?

    @ObservationIgnored
    private var finishedIDs: [UUID] = []

    @ObservationIgnored
    private var finished: [Session]?

    @ObservationIgnored
    private var histories: [History.Subject: History] = [:]

    @ObservationIgnored
    private var days: [Date: [Session]]?

    @ObservationIgnored
    private var starts: [Workout: [Date]]?

    @ObservationIgnored
    private var startMinutes: [Workout: Int?] = [:]

    @ObservationIgnored
    private var dayObserver: (any NSObjectProtocol)?

    public nonisolated init(container: ModelContainer? = nil) {
        self.container = container
    }

    isolated deinit {
        dayObserver.map(NotificationCenter.default.removeObserver)
    }
}

extension Statistics {
    public var sessions: [Session] {
        _ = revision

        if let finished {
            return finished
        }

        observe()

        let sessions = observer.map { Array($0.results) } ?? []
        finished = sessions
        return sessions
    }

    private var context: ModelContext {
        (container ?? Storage.container).mainContext
    }

    public func history(_ subject: History.Subject) -> History {
        // Read up front, so even a cached result observes the next reload. The same goes for the lookups below.
        let sessions = sessions
        let history = histories[subject] ?? History(subject, among: sessions)
        histories[subject] = history

        guard subject == .all else {
            return history
        }

        // Measurements change on Health's schedule, so they're added on every read instead of rebuilding.
        var withMeasurements = history
        withMeasurements.measurements = Health.shared.measurements
        return withMeasurements
    }

    public func sessions(on day: Date) -> [Session] {
        let sessions = sessions
        let calendar = Calendar.current
        let days = days ?? Dictionary(grouping: sessions.reversed()) { calendar.startOfDay(for: $0.localStartDate(in: calendar)) }
        self.days = days
        return days[calendar.startOfDay(for: day)] ?? []
    }

    public func lastSession(of workout: Workout, before limit: Date = .distantFuture) -> Date? {
        let sessions = sessions
        let starts = starts ?? sessions.reduce(into: [Workout: [Date]]()) { starts, session in
            if let workout = session.workout {
                starts[workout, default: []].append(session.localStartDate(in: .current))
            }
        }
        .mapValues { $0.sorted() }

        self.starts = starts
        return starts[workout]?.last { $0 < limit }
    }

    public func isScheduled(_ workout: Workout, on date: Date = .now) -> Bool {
        workout.schedule.isScheduled(on: date, after: lastSession(of: workout, before: Calendar.current.startOfDay(for: date)))
    }

    public func pending(_ workouts: [Workout]) -> [Workout] {
        workouts.pending(on: .now, calendar: .current) { lastSession(of: $0) } startMinute: { typicalStartMinute(of: $0) }
    }

    private func typicalStartMinute(of workout: Workout) -> Int? {
        if let minute = startMinutes[workout] {
            return minute
        }

        let minute = history(.workout(workout)).typicalStartMinute
        startMinutes[workout] = minute
        return minute
    }

    private func observe() {
        guard observer == nil else {
            return
        }

        do {
            let observer = try ResultsObserver<Session, Never>(fetchDescriptor: Session.finishedDescriptor, modelContext: context)
            self.observer = observer
            finishedIDs = observer.results.map(\.id)
            Logger.statistics.info("Observing \(finishedIDs.count) finished sessions")
        } catch {
            Logger.statistics.error("Observing finished sessions failed: \(error, privacy: .public)")
            return
        }

        // Changes to the active session can still notify, so only a different set of finished sessions reloads.
        token = withContinuousObservation(options: [.didSet]) { [weak self] _ in
            guard let self, let observer else {
                return
            }

            let ids = observer.results.map(\.id)

            guard ids != finishedIDs else {
                Logger.statistics.debug("Ignored a change that kept the finished sessions")
                return
            }

            Logger.statistics.info("Finished sessions changed from \(finishedIDs.count) to \(ids.count)")
            finishedIDs = ids
            reload()
        }

        // Histories are frozen at the moment they're built, so their days move at midnight.
        dayObserver = NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                Logger.statistics.info("Day changed")
                self?.reload()
            }
        }
    }

    private func reload() {
        finished = nil
        histories = [:]
        days = nil
        starts = nil
        startMinutes = [:]
        revision += 1

        Logger.statistics.info("Reloaded statistics")
    }
}
