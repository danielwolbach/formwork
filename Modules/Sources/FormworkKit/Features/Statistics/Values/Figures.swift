//
//  Figures.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Foundation

extension Session {
    var completionRate: Double? {
        let entries = entries ?? []
        return entries.isEmpty ? nil : Double(entries.count(where: \.status.isCompleted)) / Double(entries.count)
    }

    var typicalExerciseDuration: Double? {
        (entries ?? []).compactMap(\.duration).median
    }

    var completedExerciseCount: Int {
        (entries ?? []).count(where: \.status.isCompleted)
    }

    var volume: Double? {
        let volumes = (entries ?? []).filter(\.status.isCompleted).compactMap(\.target.volume)
        return volumes.isEmpty ? nil : volumes.reduce(0, +)
    }
}
