//
//  Effort.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 06.10.26.
//

import Foundation

extension History.Window {
    var typicalHeartRate: Double? {
        sessions.compactMap { $0.health?.averageHeartRate }.median
    }

    var typicalActiveEnergy: Double? {
        sessions.compactMap { $0.health?.activeEnergy }.median
    }
}
