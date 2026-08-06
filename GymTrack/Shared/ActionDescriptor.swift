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
    case type
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

    var title: LocalizedStringResource {
        switch self {
        case .createWorkout: .actionCreateWorkout
        case .createExercise: .actionCreateExercise
        case .addWorkoutExercise: .actionExerciseAdd
        case .startSession: .actionSessionStart
        case .seeStats: .actionStatsView
        case .edit: .actionEdit
        case .delete: .actionDelete
        case .remove: .actionRemove
        case .type: .actionExerciseType
        case .moreOptions: .actionOptions
        case .increase: .actionIncrease
        case .decrease: .actionDecrease
        case .confirm: .actionConfirm
        case .cancel: .actionCancel
        case .backward: .actionBackward
        case .forward: .actionForward
        case .complete: .actionComplete
        case .skip: .actionSkip
        case .queue: .actionQueue
        case .undo: .actionUndo
        case .cancelSession: .actionSessionCancel
        case .finishSession: .actionSessionFinish
        case .replaceSession: .actionSessionReplace
        case .resumeSession: .actionSessionResume
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
        case .type: "lines.measurement.horizontal"
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
