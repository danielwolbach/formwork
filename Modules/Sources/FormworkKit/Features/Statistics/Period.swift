//
//  Period.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public struct Period {
    public let history: History

    public let span: DateInterval

    public let interval: DateInterval

    public let occurrences: [Occurrence]

    init(_ history: History, span: DateInterval) {
        let start = max(span.start, history.interval.start)
        let interval = DateInterval(start: start, end: max(start, min(span.end, history.interval.end)))

        self.history = history
        self.span = span
        self.interval = interval
        self.occurrences = history.occurrences.filter { interval.start <= $0.day && $0.day < interval.end }
    }
}

extension Period {
    public var isOnRecord: Bool {
        interval.duration > 0
    }

    var completions: [Occurrence] {
        occurrences.filter(\.isCompleted)
    }
}
