//
//  Quantity.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public enum Quantity: CaseIterable, Sendable {
    case duration
    case startTime
    case endTime
    case completionRate
    case exerciseDuration
    case completedExercises
    case plannedExercises
    case volume
    case best
    case oneRepMax
}

extension Quantity: Identifiable {
    public var id: Self {
        self
    }
}

extension Quantity: Describable {
    public var title: String {
        switch self {
        case .duration: String(localized: .quantityDurationTitle)
        case .startTime: String(localized: .quantityStartTimeTitle)
        case .endTime: String(localized: .quantityEndTimeTitle)
        case .completionRate: String(localized: .quantityCompletionRateTitle)
        case .exerciseDuration: String(localized: .quantityExerciseDurationTitle)
        case .completedExercises: String(localized: .quantityCompletedExercisesTitle)
        case .plannedExercises: String(localized: .quantityPlannedExercisesTitle)
        case .volume: String(localized: .quantityVolumeTitle)
        case .best: String(localized: .quantityBestTitle)
        case .oneRepMax: String(localized: .quantityOneRepMaxTitle)
        }
    }

    public var info: String {
        switch self {
        case .duration: String(localized: .quantityDurationInfo)
        case .startTime: String(localized: .quantityStartTimeInfo)
        case .endTime: String(localized: .quantityEndTimeInfo)
        case .completionRate: String(localized: .quantityCompletionRateInfo)
        case .exerciseDuration: String(localized: .quantityExerciseDurationInfo)
        case .completedExercises: String(localized: .quantityCompletedExercisesInfo)
        case .plannedExercises: String(localized: .quantityPlannedExercisesInfo)
        case .volume: String(localized: .quantityVolumeInfo)
        case .best: String(localized: .quantityBestInfo)
        case .oneRepMax: String(localized: .quantityOneRepMaxInfo)
        }
    }

    public var pictogram: Pictogram {
        switch self {
        case .duration: .duration
        case .startTime, .endTime: .time
        case .completionRate: .completed
        case .exerciseDuration: .pace
        case .completedExercises, .plannedExercises: .tally
        case .volume: .volume
        case .best: .record
        case .oneRepMax: .strength
        }
    }
}

extension Quantity {
    public static var figures: [Quantity] {
        [.duration, .endTime, .completionRate, .exerciseDuration, .completedExercises, .volume]
    }

    var isClock: Bool {
        switch self {
        case .startTime, .endTime: true
        default: false
        }
    }

    public func reading(of session: Session, calendar: Calendar = .current) -> Reading? {
        value(of: Occurrence(session, in: calendar), in: calendar).map { Reading($0, as: unit(of: nil, in: calendar)) }
    }

    func unit(of kind: Exercise.Kind?, in calendar: Calendar) -> Reading.Unit {
        switch self {
        case .duration, .exerciseDuration: .duration
        case .startTime, .endTime: .time(calendar)
        case .completionRate: .percent
        case .completedExercises, .plannedExercises: .count
        case .volume, .oneRepMax: .weight
        case .best: .rank(kind)
        }
    }

    func unit(in history: History) -> Reading.Unit {
        unit(of: history.subject.exercise?.kind, in: history.calendar)
    }

    func value(of occurrence: Occurrence, in calendar: Calendar) -> Double? {
        let entries = occurrence.entries
        let completed = entries.filter(\.status.isCompleted)

        // What was planned counts whether it was done or not.
        switch self {
        case .completedExercises: return Double(completed.count)
        case .plannedExercises: return Double(entries.count)
        case .completionRate: return entries.isEmpty ? nil : Double(completed.count) / Double(entries.count)
        default: break
        }

        guard occurrence.isCompleted else {
            return nil
        }

        return switch self {
        case .duration: occurrence.duration
        case .startTime: occurrence.session.startMinute(in: calendar).map(Double.init)
        case .endTime: occurrence.session.endMinute(in: calendar).map(Double.init)
        case .exerciseDuration: entries.compactMap(\.duration).median
        case .volume: completed.compactMap(\.target.volume).sum
        case .best: occurrence.entry.flatMap { entry in entry.target.exerciseKind == entry.exercise?.kind ? entry.target.rank : nil }
        case .oneRepMax: completed.compactMap(\.oneRepMax).max()
        case .completedExercises, .plannedExercises, .completionRate: nil
        }
    }
}

extension SessionEntry {
    fileprivate var oneRepMax: Double? {
        guard case let .weight(kilograms, reps, _) = target, reps > 0 else {
            return nil
        }

        return kilograms * (1 + Double(reps) / 30)
    }
}
