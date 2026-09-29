//
//  Indicator.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

public protocol Indicator: Statistic {
    var reading: Reading? {
        get
    }
}
