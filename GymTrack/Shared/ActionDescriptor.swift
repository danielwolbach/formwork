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
    case increase
    case decrease
    case confirm
    case cancel
    case backward
    case forward
    case complete
    case skip
    case queue
    case undo
    case cancelSession
    case finishSession
    case replaceSession
    case resumeSession

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
        case .increase: "Increase"
        case .decrease: "Decrease"
        case .confirm: "Confirm"
        case .cancel: "Cancel"
        case .backward: "Backward"
        case .forward: "Forward"
        case .complete: "Complete"
        case .skip: "Skip"
        case .queue: "Queue"
        case .undo: "Undo"
        case .cancelSession: "Cancel Session"
        case .finishSession: "Finish"
        case .replaceSession: "Replace Session"
        case .resumeSession: "Resume Active Session"
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
        case .increase: "plus"
        case .decrease: "minus"
        case .confirm: "checkmark"
        case .cancel: "xmark"
        case .backward: "backward.fill"
        case .forward: "forward.fill"
        case .complete: "checkmark"
        case .skip: "arrow.turn.up.right"
        case .queue: "line.3.horizontal.decrease"
        case .undo: "arrow.uturn.backward"
        case .cancelSession: "xmark"
        case .finishSession: "flag.pattern.checkered"
        case .replaceSession: "restart"
        case .resumeSession: "arrowshape.turn.up.forward"
        }
    }

    var role: ButtonRole? {
        switch self {
        case .delete, .remove, .cancelSession, .replaceSession: .destructive
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
