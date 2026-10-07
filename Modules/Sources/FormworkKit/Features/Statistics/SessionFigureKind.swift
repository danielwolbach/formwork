//
//  SessionFigureKind.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

/// Something one session has. Unlike a statistic it describes a session, not a stretch of time.
public enum SessionFigureKind: CaseIterable, Sendable {
    case duration
    case endTime
    case completionRate
    case exerciseDuration
    case completedExercises
    case volume
    case averageHeartRate
    case activeEnergy

    /// Everything a session figure brings of its own. Its card, comparison and chart follow from its `value`.
    public struct Definition {
        enum Value {
            /// A number whose usual value is the median of the sessions before, compared within `tolerance`.
            case measure(Reading.Unit, tolerance: Double, (Session) -> Double?)
            /// A minute of the day on the session's clock, whose usual value is the medoid. It never compares.
            case clock((Session, Calendar) -> Int?)
        }

        public let pictogram: Pictogram

        let value: Value

        private let titleResource: LocalizedStringResource

        private let infoResource: LocalizedStringResource

        init(title: LocalizedStringResource, info: LocalizedStringResource, pictogram: Pictogram, value: Value) {
            self.pictogram = pictogram
            self.value = value
            self.titleResource = title
            self.infoResource = info
        }
    }
}

extension SessionFigureKind.Definition {
    public var title: String {
        String(localized: titleResource)
    }

    public var info: String {
        String(localized: infoResource)
    }
}

extension SessionFigureKind: Identifiable {
    public var id: Self {
        self
    }
}

extension SessionFigureKind {
    public var definition: Definition {
        switch self {
        case .duration:
            Definition(
                title: .sessionFigureDurationTitle,
                info: .sessionFigureDurationInfo,
                pictogram: .duration,
                value: .measure(.duration, tolerance: 0.05) { $0.duration }
            )
        case .endTime:
            Definition(
                title: .sessionFigureEndTimeTitle,
                info: .sessionFigureEndTimeInfo,
                pictogram: .time,
                value: .clock { $0.endMinute(in: $1) }
            )
        case .completionRate:
            Definition(
                title: .sessionFigureCompletionRateTitle,
                info: .sessionFigureCompletionRateInfo,
                pictogram: .completed,
                value: .measure(.percent, tolerance: 0.05) { $0.completionRate }
            )
        case .exerciseDuration:
            Definition(
                title: .sessionFigureExerciseDurationTitle,
                info: .sessionFigureExerciseDurationInfo,
                pictogram: .pace,
                value: .measure(.duration, tolerance: 0.05) { $0.typicalExerciseDuration }
            )
        case .completedExercises:
            Definition(
                title: .sessionFigureCompletedExercisesTitle,
                info: .sessionFigureCompletedExercisesInfo,
                pictogram: .tally,
                value: .measure(.count, tolerance: 0.05) { Double($0.completedExerciseCount) }
            )
        case .volume:
            Definition(
                title: .sessionFigureVolumeTitle,
                info: .sessionFigureVolumeInfo,
                pictogram: .volume,
                value: .measure(.weight, tolerance: 0.05) { $0.volume }
            )
        case .averageHeartRate:
            Definition(
                title: .sessionFigureAverageHeartRateTitle,
                info: .sessionFigureAverageHeartRateInfo,
                pictogram: .heartRate,
                value: .measure(.heartRate, tolerance: 0.05) { $0.health?.averageHeartRate }
            )
        case .activeEnergy:
            Definition(
                title: .sessionFigureActiveEnergyTitle,
                info: .sessionFigureActiveEnergyInfo,
                pictogram: .energy,
                value: .measure(.energy, tolerance: 0.05) { $0.health?.activeEnergy }
            )
        }
    }

    public func reading(of session: Session, calendar: Calendar = .current) -> Reading? {
        switch definition.value {
        case let .measure(unit, _, value): value(session).map { Reading($0, as: unit) }
        case let .clock(minute): minute(session, calendar).flatMap { Reading(minuteOfDay: $0, in: calendar) }
        }
    }

    /// For a chart's axis: how a measure reads at `value`. Clock figures don't chart.
    public func reading(of value: Double) -> Reading? {
        guard case let .measure(unit, _, _) = definition.value else {
            return nil
        }

        return Reading(value, as: unit)
    }
}
