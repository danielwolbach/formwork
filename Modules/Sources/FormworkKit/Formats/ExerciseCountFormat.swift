//
//  ExerciseCountFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public struct ExerciseCountFormat: FormatStyle {
    public init() {
        // Nothing to initialize.
    }

    public func format(_ count: Int) -> String {
        String(localized: .formatExerciseCountScheme(count: count))
    }
}

extension FormatStyle where Self == ExerciseCountFormat {
    public static var exerciseCount: ExerciseCountFormat {
        ExerciseCountFormat()
    }
}
