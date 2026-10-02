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

    static var pictogram: Pictogram {
        get
    }

    static var title: String {
        get
    }

    init(_ window: History.Window)
}
