//
//  Direction.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

public enum Direction: Sendable {
    case up
    case down
    case flat
}

extension Direction {
    init?(from old: Double?, to new: Double?, tolerance: Double) {
        guard let old, let new else {
            return nil
        }

        guard old != 0 else {
            self = new == 0 ? .flat : .up
            return
        }

        let change = (new - old) / abs(old)
        self = abs(change) <= tolerance ? .flat : change > 0 ? .up : .down
    }

    public var image: String {
        switch self {
        case .up: "arrow.up.forward"
        case .down: "arrow.down.forward"
        case .flat: "arrow.forward"
        }
    }
}
