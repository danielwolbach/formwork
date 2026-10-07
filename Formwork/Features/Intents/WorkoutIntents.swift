//
//  WorkoutIntents.swift
//  Formwork
//
//  Created by Daniel Wolbach on 07.10.26.
//

import AppIntents
import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct OpenWorkoutIntent: OpenIntent, TargetContentProvidingIntent {
    static let title: LocalizedStringResource = "intent.openWorkout.title"

    @Parameter(title: "intent.workout.title", requestValueDialog: "intent.workout.prompt")
    var target: WorkoutEntity
}

struct StartSessionIntent: AppIntent, TargetContentProvidingIntent {
    static let title: LocalizedStringResource = "intent.startSession.title"

    static let supportedModes: IntentModes = .foreground

    @Parameter(title: "intent.workout.title", requestValueDialog: "intent.workout.prompt")
    var workout: WorkoutEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Start \(\.$workout)")
    }
}
