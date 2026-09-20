//
//  SessionSummary.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import Foundation

public struct SessionSummary {
    /// How long the session ran, from when it was started to when it was finished.
    public let duration: Statistic<Duration>

    /// When the session was finished, on the clock where it was recorded.
    public let endTime: Statistic<Date>

    /// The share of the session's exercises that were skipped, rather than completed or left pending.
    public let skipRate: Statistic<Double>

    /// How long a typical exercise took, so it covers the rest before each one. The median of
    /// `SessionEntry.elapsed`, which is what the session's exercises show, so one long interruption skews
    /// it no more than the mean of two would.
    public let medianExerciseDuration: Statistic<Duration>

    /// How many of the session's exercises were completed, rather than skipped or left pending.
    public let completedExercises: Statistic<Int>

    /// The weight moved by the exercises that were completed: load times sets times reps, added up.
    public let totalVolume: Statistic<Quantity>

    init(session: Session, calendar: Calendar = .current) {
        let entries = session.entries
        let durations = entries.compactMap(\.elapsed)
        let completed = entries.filter(\.status.isCompleted)
        let volumes = completed.compactMap(\.target.volume)

        // Keeping the first one's unit reads the total back in whatever the weights were logged in.
        var volume = volumes.first
        volume?.base = volumes.reduce(0) { $0 + $1.base }

        self.duration = .duration(session.duration.map { .seconds($0) })
        self.endTime = .endTime(session.ended, in: session, calendar: calendar)
        self.skipRate = .skipRate(entries.isEmpty ? nil : Double(entries.count(where: \.status.isSkipped)) / Double(entries.count))
        self.medianExerciseDuration = .medianExerciseDuration(durations.median.map { .seconds($0) })
        self.completedExercises = .completedExercises(completed.count)
        self.totalVolume = .totalVolume(volume)
    }
}

public extension Session {
    func summary() -> SessionSummary {
        SessionSummary(session: self)
    }
}
