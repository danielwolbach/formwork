//
//  StatisticDetails.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public struct StatisticDetails {
    public enum Value: Hashable {
        case trend(recent: Reading?, before: Reading?, direction: Trend.Direction?)
        case recent(Reading?)
        case overall(Reading?)
        case named(String, Reading?, footnote: String? = nil)
    }

    public enum Chart {
        case monthly(Series<Double?>, reading: (Double) -> Reading)
        case activeDays(ActiveDays)
        case categories(Series<Categories>)
        case progression(Progression)
    }

    public struct Sessions {
        public let period: DateInterval

        public let points: [SessionComparison.Point]

        public let reading: (Double) -> Reading

        init(_ history: History, reading: @escaping (Double) -> Reading, values: (History.Window) -> [(date: Date, value: Double?)]) {
            let window = history.days(History.comparedWeeks * 7, endingOn: history.now)

            self.period = window.period
            self.points = values(window).enumerated().map { index, point in
                SessionComparison.Point(id: index, date: point.date, value: point.value, isCurrent: false)
            }
            self.reading = reading
        }
    }

    public struct Yearly {
        public let years: ClosedRange<Int>

        public let chart: (Int) -> Chart

        init(_ history: History, years: ClosedRange<Int>? = nil, chart: @escaping (Int) -> Chart) {
            self.years = years ?? history.years
            self.chart = chart
        }
    }

    public let values: [Value]

    public let categories: (recent: Categories, overall: Categories)?

    public let sessions: Sessions?

    public let yearly: Yearly?

    init(values: [Value] = [], categories: (recent: Categories, overall: Categories)? = nil, sessions: Sessions? = nil, yearly: Yearly? = nil) {
        self.values = values
        self.categories = categories
        self.sessions = sessions
        self.yearly = yearly
    }
}
