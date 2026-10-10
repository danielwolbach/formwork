//
//  SessionFigureKind.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public enum SessionFigureKind: CaseIterable, Sendable {
    case duration
    case endTime
    case completionRate
    case exerciseDuration
    case completedExercises
    case volume
    case averageHeartRate

    public enum Value {
        case measure(Reading.Unit, tolerance: Double, (Session) -> Double?)
        case clock((Session, Calendar) -> Int?)
    }
}

extension SessionFigureKind: Identifiable {
    public var id: Self {
        self
    }
}

extension SessionFigureKind {
    public var definition: Definition<Value> {
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
        }
    }

    public func reading(of session: Session, calendar: Calendar = .current) -> Reading? {
        switch definition.value {
        case let .measure(unit, _, value): value(session).map { Reading($0, as: unit) }
        case let .clock(minute): minute(session, calendar).flatMap { Reading(minuteOfDay: $0, in: calendar) }
        }
    }

    public func reading(of value: Double) -> Reading? {
        guard case let .measure(unit, _, _) = definition.value else {
            return nil
        }

        return Reading(value, as: unit)
    }
}
