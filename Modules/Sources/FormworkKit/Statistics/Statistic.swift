//
//  Statistic.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public protocol Statistic {
    static var info: String {
        get
    }

    var pictogram: Pictogram {
        get
    }

    var title: String {
        get
    }

    /// The value as text, the same wherever the statistic is shown. Chart statistics have none.
    var formattedValue: String? {
        get
    }

    init(_ window: History.Window)
}
