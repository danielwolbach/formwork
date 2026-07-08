//
//  Exercise+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension Exercise {
    var systemImage: String {
        metric.systemImage
    }
}

extension Exercise {
    var color: Color {
        metric.color
    }
}

extension Exercise {
    static let systemImage = "dumbbell"
}

extension Exercise {
    static let color = Color.accentColor
}
