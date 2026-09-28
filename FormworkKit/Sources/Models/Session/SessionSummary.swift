//
//  SessionSummary.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import Foundation

public struct SessionSummary {
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

    public let duration: Figure<Duration>

    public let endTime: Figure<Date>

    public let skipRate: Figure<Double>

    public let medianExerciseDuration: Figure<Duration>

    public let completedExercises: Figure<Int>

    public let totalVolume: Figure<Double>

    init(session: Session, calendar: Calendar = .current) {
        let entries = session.entries
        let durations = entries.compactMap(\.duration)
        let completed = entries.filter(\.status.isCompleted)
        let volumes = completed.compactMap(\.target.volume)

        self.duration = .duration(session.duration.map { .seconds($0) })
        self.endTime = .endTime(session.endDate, in: session, calendar: calendar)
        self.skipRate = .skipRate(entries.isEmpty ? nil : Double(entries.count(where: \.status.isSkipped)) / Double(entries.count))
        self.medianExerciseDuration = .medianExerciseDuration(durations.median.map { .seconds($0) })
        self.completedExercises = .completedExercises(completed.count)
        self.totalVolume = .totalVolume(volumes.isEmpty ? nil : volumes.reduce(0, +))
    }
}

extension Session {
    public func summary() -> SessionSummary {
        SessionSummary(session: self)
    }
}

extension SessionSummary.Figure where Value == Duration {
    static func duration(_ duration: Duration?) -> Self {
        Self(duration, title: String(localized: .placeholder), pictogram: .duration) {
            $0.formatted(.sessionDuration)
        }
    }

    static func medianExerciseDuration(_ duration: Duration?) -> Self {
        Self(duration, title: String(localized: .placeholder), pictogram: .pace) {
            $0.formatted(.exerciseDuration)
        }
    }
}

extension SessionSummary.Figure where Value == Date {
    static func endTime(_ date: Date?, in session: Session?, calendar: Calendar) -> Self {
        let local = session?.localCalendar(from: calendar) ?? calendar

        return Self(date, title: String(localized: .placeholder), pictogram: .time) {
            $0.formatted(local.formatStyle(time: .shortened))
        }
    }
}

extension SessionSummary.Figure where Value == Double {
    static func skipRate(_ rate: Double?) -> Self {
        Self(rate, title: String(localized: .placeholder), pictogram: .skipped) {
            $0.formatted(.percent.precision(.fractionLength(0)))
        }
    }

    static func totalVolume(_ volume: Double?) -> Self {
        Self(volume, title: String(localized: .placeholder), pictogram: .volume) {
            $0.formatted(TargetFormat(kind: .weight, system: .current))
        }
    }
}

extension SessionSummary.Figure where Value == Int {
    static func completedExercises(_ count: Int) -> Self {
        Self(count, title: String(localized: .placeholder), pictogram: .completed) {
            $0.formatted()
        }
    }
}
