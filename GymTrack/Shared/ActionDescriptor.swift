//
//  ActionDescriptor.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

enum ActionDescriptor {
    case createWorkout
    case createExercise
    case addWorkoutExercise
    case startSession
    case seeStats
    case edit
    case delete
    case remove
    case metric
    case moreOptions
    case confirm
    case cancel

    var title: LocalizedStringKey {
        switch self {
        case .createWorkout: "Create Workout"
        case .createExercise: "Create Exercise"
        case .addWorkoutExercise: "Add Exercise"
        case .startSession: "Start Session"
        case .seeStats: "See Stats"
        case .edit: "Edit"
        case .delete: "Delete"
        case .remove: "Remove"
        case .metric: "Metric"
        case .moreOptions: "More Options"
        case .confirm: "Confirm"
        case .cancel: "Cancel"
        }
    }

    var systemImage: String {
        switch self {
        case .createWorkout: "plus"
        case .createExercise: "plus"
        case .addWorkoutExercise: "text.badge.plus"
        case .startSession: "play.fill"
        case .seeStats: "chart.pie"
        case .edit: "pencil"
        case .delete: "trash"
        case .remove: "minus.circle"
        case .metric: "lines.measurement.horizontal"
        case .moreOptions: "ellipsis"
        case .confirm: "checkmark"
        case .cancel: "xmark"
        }
    }

    var role: ButtonRole? {
        switch self {
        case .delete, .remove: .destructive
        case .confirm: .confirm
        case .cancel: .cancel
        default: nil
        }
    }
}

extension Button where Label == SwiftUI.Label<Text, Image> {
    init(_ descriptor: ActionDescriptor, action: @escaping () -> Void) {
        self.init(
            descriptor.title,
            systemImage: descriptor.systemImage,
            role: descriptor.role,
            action: action
        )
    }
}

extension Menu where Label == SwiftUI.Label<Text, Image> {
    init(_ descriptor: ActionDescriptor, @ViewBuilder content: () -> Content) {
        self.init(
            descriptor.title,
            systemImage: descriptor.systemImage,
            content: content
        )
    }
}
