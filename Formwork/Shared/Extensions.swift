//
//  Extensions.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

extension Binding where Value == String {
    func animated() -> Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { newValue in withAnimation(.snappy) { wrappedValue = newValue } }
        )
    }
}

extension Date? {
    func relativeDayDescription(now: Date = .now) -> String {
        if self == nil {
            return String(localized: .dateNeverTitle)
        }
        
        let calendar = Calendar.autoupdatingCurrent

        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: self!),
            to: calendar.startOfDay(for: now)
        ).day ?? 0

        switch days {
        case 0:
            return String(localized: .dateTodayTitle)
        case 1 ... 6:
            // Shift `now` back by whole days so `.relative` measures calendar
            // days rather than the interval between the two instants.
            let shifted = calendar.date(byAdding: .day, value: -days, to: now) ?? self!
            return shifted.formatted(.relative(presentation: .named))
        default:
            return self!.formatted(.dateTime.day().month(.abbreviated))
        }
    }
}
