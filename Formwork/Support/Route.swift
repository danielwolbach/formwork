//
//  Route.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftUI

enum Route: Hashable, View {
    case sessions
    case workoutStatistics(workout: Workout)

    var body: some View {
        switch self {
        case .sessions: SessionListScreen()
        case let .workoutStatistics(workout): WorkoutStatisticsScreen(workout: workout)
        }
    }
}
