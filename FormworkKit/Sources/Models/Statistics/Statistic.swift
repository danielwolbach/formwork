//
//  Statistic.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public protocol Statistic: Displayable {
    static var info: String {
        get
    }

    init(_ window: History.Window)
}
