//
//  SessionSummary.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import Foundation

public struct SessionSummary {
    /// One value of the session, and how to show it.
    public struct Figure<Value>: Displayable {
        public let pictogram: Pictogram

        public let title: String

        public let subtitle: String?

        let value: Value?

        init(_ value: Value?, title: String, pictogram: Pictogram, format: (Value) -> String?) {
            self.value = value
            self.title = title
            self.pictogram = pictogram
            self.subtitle = value.flatMap(format)
        }
    }

    /// How long the session ran, from when it was started to when it was finished.
    public let duration: Figure<Duration>

    /// When the session was finished, on the clock where it was recorded.
    public let endTime: Figure<Date>

    /// The share of the session's exercises that were skipped, rather than completed or left pending.
    public let skipRate: Figure<Double>

    /// How long a typical exercise took, so it covers the rest before each one. The median of
    /// `SessionEntry.duration`, which is what the session's exercises show, so one long interruption skews
    /// it no more than the mean of two would.
    public let medianExerciseDuration: Figure<Duration>

    /// How many of the session's exercises were completed, rather than skipped or left pending.
    public let completedExercises: Figure<Int>

    /// The weight moved by the exercises that were completed: load times sets times reps, added up.
    public let totalVolume: Figure<Quantity>

    init(session: Session, calendar: Calendar = .current) {
        let entries = session.entries
        let durations = entries.compactMap(\.duration)
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

extension Session {
    public func summary() -> SessionSummary {
        SessionSummary(session: self)
    }
}

extension SessionSummary.Figure where Value == Duration {
    static func duration(_ duration: Duration?) -> Self {
        Self(duration, title: String(localized: .statisticDurationTitle), pictogram: .duration) {
            $0.formatted(.sessionDuration)
        }
    }

    static func medianExerciseDuration(_ duration: Duration?) -> Self {
        Self(duration, title: String(localized: .statisticMedianExerciseDurationTitle), pictogram: .pace) {
            $0.formatted(.exerciseDuration)
        }
    }
}

extension SessionSummary.Figure where Value == Date {
    static func endTime(_ date: Date?, in session: Session?, calendar: Calendar) -> Self {
        let local = session?.localCalendar(from: calendar) ?? calendar

        return Self(date, title: String(localized: .statisticEndTimeTitle), pictogram: .time) {
            $0.formatted(local.formatStyle(time: .shortened))
        }
    }
}

extension SessionSummary.Figure where Value == Double {
    static func skipRate(_ rate: Double?) -> Self {
        Self(rate, title: String(localized: .statisticSkipRateTitle), pictogram: .skipped) {
            $0.formatted(.percent.precision(.fractionLength(0)))
        }
    }
}

extension SessionSummary.Figure where Value == Int {
    static func completedExercises(_ count: Int) -> Self {
        Self(count, title: String(localized: .statisticCompletedExercisesTitle), pictogram: .completed) {
            $0.formatted()
        }
    }
}

extension SessionSummary.Figure where Value == Quantity {
    static func totalVolume(_ volume: Quantity?) -> Self {
        Self(volume, title: String(localized: .statisticTotalVolumeTitle), pictogram: .volume) {
            $0.formatted
        }
    }
}
