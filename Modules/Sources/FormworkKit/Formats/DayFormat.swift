//
//  DayFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 12.10.26.
//

import Foundation

struct DayFormat: FormatStyle {
    let calendar: Calendar

    func format(_ date: Date) -> String {
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now), date < weekAgo else {
            var style = Date.RelativeFormatStyle(presentation: .named, calendar: calendar, capitalizationContext: .beginningOfSentence)
            style.allowedFields = [.day]
            return date.formatted(style)
        }

        let style = calendar.formatStyle().day().month()
        return calendar.isDate(date, equalTo: .now, toGranularity: .year) ? date.formatted(style) : date.formatted(style.year())
    }
}
