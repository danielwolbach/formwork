//
//  Statistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation
import SwiftData

@MainActor
@Observable
public final class Statistics {
    private let container: ModelContainer?

    private var revision = 0

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
    private var observers: [any NSObjectProtocol] = []

    public nonisolated init(container: ModelContainer? = nil) {
        self.container = container
    }

    isolated deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }
}

extension Statistics {
    public var sessions: [Session] {
        _ = revision

        if let finished {
            return finished
        }

        observe()

        let sessions = (try? context.fetch(Session.finishedDescriptor)) ?? []
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
        guard observers.isEmpty else {
            return
        }

        let center = NotificationCenter.default

        observers = [
            center.addObserver(forName: ModelContext.didSave, object: nil, queue: .main) { [weak self] notification in
                let keys: [ModelContext.NotificationKey] = [.insertedIdentifiers, .updatedIdentifiers, .deletedIdentifiers]
                let changed = keys.flatMap { notification.userInfo?[$0.rawValue] as? [PersistentIdentifier] ?? [] }

                MainActor.assumeIsolated {
                    self?.reload(after: changed)
                }
            },
            // Histories are frozen at the moment they're built, so their days move at midnight.
            center.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.reload()
                }
            },
        ]
    }

    private func reload(after changed: [PersistentIdentifier]) {
        if let active = try? Session.active(in: context) {
            let ignored = Set([active.persistentModelID] + (active.entries ?? []).map(\.persistentModelID))

            guard !changed.allSatisfy(ignored.contains) else {
                return
            }
        }

        reload()
    }

    private func reload() {
        finished = nil
        histories = [:]
        days = nil
        starts = nil
        startMinutes = [:]
        revision += 1
    }
}
