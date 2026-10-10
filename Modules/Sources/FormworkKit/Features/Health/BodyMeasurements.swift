//
//  BodyMeasurements.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public struct BodyMeasurements: Hashable, Sendable {
    public enum Kind: CaseIterable, Sendable {
        case weight
        case bodyFat
    }

    public struct Sample: Hashable, Sendable {
        public let date: Date

        public let value: Double

        public init(date: Date, value: Double) {
            self.date = date
            self.value = value
        }
    }

    public var weight: [Sample]

    public var bodyFat: [Sample]

    public init(weight: [Sample] = [], bodyFat: [Sample] = []) {
        self.weight = weight
        self.bodyFat = bodyFat
    }
}

extension BodyMeasurements {
    public subscript(kind: Kind) -> [Sample] {
        get {
            switch kind {
            case .weight: weight
            case .bodyFat: bodyFat
            }
        }

        set {
            switch kind {
            case .weight: weight = newValue
            case .bodyFat: bodyFat = newValue
            }
        }
    }

    func within(_ interval: DateInterval) -> BodyMeasurements {
        let contains = { (sample: Sample) in interval.start <= sample.date && sample.date < interval.end }
        return BodyMeasurements(weight: weight.filter(contains), bodyFat: bodyFat.filter(contains))
    }
}

extension BodyMeasurements.Kind {
    var unit: Reading.Unit {
        switch self {
        case .weight: .weight
        case .bodyFat: .percent
        }
    }
}
