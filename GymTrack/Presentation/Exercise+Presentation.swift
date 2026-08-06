//
//  Exercise+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

@MainActor
extension Exercise {
    var title: String {
        name
    }

    var subtitle: String {
        disciplines.map { String(localized: $0.title) }.sorted().joined(separator: ", ")
    }

    var color: Color {
        type.color
    }

    var icon: String {
        type.icon
    }

    static var genericIcon: String {
        "dumbbell"
    }
}
