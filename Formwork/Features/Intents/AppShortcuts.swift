//
//  AppShortcuts.swift
//  Formwork
//
//  Created by Daniel Wolbach on 07.10.26.
//

import AppIntents
import FormworkKit

struct AppShortcuts: AppShortcutsProvider {
    static let shortcutTileColor: ShortcutTileColor = .navy

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartSessionIntent(),
            phrases: [
                "Start a workout in \(.applicationName)",
                "Start a session in \(.applicationName)",
                "Start \(\.$workout) in \(.applicationName)",
                "Start session for \(\.$workout) in \(.applicationName)",
            ],
            shortTitle: "intent.startSession.title",
            systemImageName: "play",
            parameterPresentation: ParameterPresentation(
                for: \.$workout,
                summary: Summary("Start \(\.$workout)"),
                optionsCollections: {
                    OptionsCollection(WorkoutEntityQuery(), title: "intent.session.title", systemImageName: "play.fill")
                }
            )
        )

        AppShortcut(
            intent: OpenWorkoutIntent(),
            phrases: [
                "Open a workout in \(.applicationName)",
                "Open \(\.$target) in \(.applicationName)",
                "Show \(\.$target) in \(.applicationName)",
            ],
            shortTitle: "intent.openWorkout.title",
            systemImageName: "clipboard",
            parameterPresentation: ParameterPresentation(
                for: \.$target,
                summary: Summary("Open \(\.$target)"),
                optionsCollections: {
                    OptionsCollection(WorkoutEntityQuery(), title: "intent.workout.title", systemImageName: "clipboard")
                }
            )
        )
    }
}
