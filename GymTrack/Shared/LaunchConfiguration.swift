//
//  LaunchConfiguration.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 07.08.26.
//

import Foundation

enum LaunchConfiguration {
    static var sampleData: Bool {
        #if DEBUG
            ProcessInfo.processInfo.arguments.contains("--sample-data")
        #else
            false
        #endif
    }
}
