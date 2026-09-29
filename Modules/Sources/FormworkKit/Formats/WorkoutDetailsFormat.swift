//
//  WorkoutDetailsFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public struct WorkoutDetailsFormat: FormatStyle {
    let now: Date

    public init(at now: Date = .now) {
        self.now = now
    }

    public func format(_ workout: Workout) -> String {
        let count = workout.entries.count.formatted(.exerciseCount)
        let duration = TypicalDuration(History(.workout(workout), at: now).recent).value.map(DurationFormat().format)

        return [count, duration].compactMap(\.self).formatted(.dotList)
    }
}

extension FormatStyle where Self == WorkoutDetailsFormat {
    public static var workoutDetails: WorkoutDetailsFormat {
        WorkoutDetailsFormat()
    }
}

extension Workout {
    public func formatted<Style: FormatStyle>(_ style: Style) -> Style.FormatOutput where Style.FormatInput == Workout {
        style.format(self)
    }
}
