//
//  Workout+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import Foundation
import SwiftUI

extension Workout {
    var title: String {
        name
    }

    var subtitle: String {
        String(localized: .workoutEntryCount(count: entries.count))
    }

    var color: Color {
        .accentColor
    }

    var icon: String {
        "clipboard"
    }

    static var genericIcon: String {
        "clipboard"
    }
}
