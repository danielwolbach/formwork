//
//  ExerciseCountFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public struct ExerciseCountFormat: FormatStyle {
    public init() {}

    public func format(_ count: Int) -> String {
        String(localized: .exerciseCount(count: count))
    }
}

extension FormatStyle where Self == ExerciseCountFormat {
    public static var exerciseCount: ExerciseCountFormat {
        ExerciseCountFormat()
    }
}
