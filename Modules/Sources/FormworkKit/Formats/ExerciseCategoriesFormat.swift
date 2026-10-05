//
//  ExerciseCategoriesFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public struct ExerciseCategoriesFormat: FormatStyle {
    public init() {
        // Nothing to initialize.
    }

    public func format(_ categories: Set<Exercise.Category>) -> String {
        Exercise.Category.allCases
            .filter(categories.contains)
            .map(\.title)
            .formatted(.list(type: .and, width: .narrow))
    }
}

extension FormatStyle where Self == ExerciseCategoriesFormat {
    public static var exerciseCategories: ExerciseCategoriesFormat {
        ExerciseCategoriesFormat()
    }
}
