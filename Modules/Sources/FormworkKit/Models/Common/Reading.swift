//
//  Reading.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public enum Reading: Hashable, Sendable {
    case count(Int)
    case percent(Double)
    case rate(Double)
    case weight(kilograms: Double)
    case distance(meters: Double)
    case duration(seconds: Double)
    case days(Double)
    case reps(Int)
    case name(String)
    case day(Date, calendar: Calendar)
    case time(Date, calendar: Calendar)
}

extension Reading {
    public init(rank: Double, of kind: Exercise.Kind?) {
        self = switch kind {
        case .weight: .weight(kilograms: rank)
        case .bodyweight: .reps(Int(rank.rounded()))
        case .duration: .duration(seconds: rank)
        case .distance: .distance(meters: rank)
        case nil: .count(Int(rank.rounded()))
        }
    }
}
