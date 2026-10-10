//
//  StatisticSummary.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public enum StatisticSummary {
    case reading(Reading?, direction: Trend.Direction?)
    case activeDays(ActiveDays)
    case categories(Categories)
    case progression(Progression)
}
