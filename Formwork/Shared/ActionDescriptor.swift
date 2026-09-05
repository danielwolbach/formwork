//
//  Action.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct ActionDescriptor {
    let title: LocalizedStringResource
    let systemImage: String
    let role: ButtonRole?

    init(title: LocalizedStringResource, systemImage: String, role: ButtonRole? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
    }
}

extension ActionDescriptor {
    // Generic
    static let placeholder = ActionDescriptor(title: .commonPlaceholderTitle, systemImage: "questionmark")
    static let delete = ActionDescriptor(title: .actionDeleteTitle, systemImage: "trash", role: .destructive)
    static let create = ActionDescriptor(title: .actionCreateTitle, systemImage: "plus")
    static let edit = ActionDescriptor(title: .actionEditTitle, systemImage: "pencil")
    static let confirm = ActionDescriptor(title: .actionConfirmTitle, systemImage: "checkmark", role: .confirm)
    static let cancel = ActionDescriptor(title: .actionCancelTitle, systemImage: "xmark", role: .cancel)
    static let more = ActionDescriptor(title: .actionMoreTitle, systemImage: "ellipsis")
    static let stats = ActionDescriptor(title: .actionStatsTitle, systemImage: "chart.pie")
    static let remove = ActionDescriptor(title: .actionRemoveTitle, systemImage: "minus.circle", role: .destructive)
    static let increase = ActionDescriptor(title: .actionIncreaseTitle, systemImage: "plus")
    static let decrease = ActionDescriptor(title: .actionDecreaseTitle, systemImage: "minus")
    static let forward = ActionDescriptor(title: .actionForwardTitle, systemImage: "chevron.forward")
    static let backward = ActionDescriptor(title: .actionBackwardTitle, systemImage: "chevron.backward")
    static let complete = ActionDescriptor(title: .actionCompleteTitle, systemImage: "checkmark")
    static let undo = ActionDescriptor(title: .actionUndoTitle, systemImage: "arrow.uturn.backward")
    static let minimize = ActionDescriptor(title: .actionMinimizeTitle, systemImage: "chevron.down")
    
    // Workout
    static let startSession = ActionDescriptor(title: .actionStartSessionTitle, systemImage: "play.fill")
    static let replaceSession = ActionDescriptor(title: .actionReplaceSessionTitle, systemImage: "arrow.trianglehead.2.clockwise", role: .destructive)
    static let resumeSession = ActionDescriptor(title: .actionResumeSessionTitle, systemImage: "play.fill")
    static let addExercise = ActionDescriptor(title: .actionAddExerciseTitle, systemImage: "text.badge.plus")
    
    // Session
    static let skipExercise = ActionDescriptor(title: .actionSkipExerciseTitle, systemImage: "forward.end")
    static let openQueue = ActionDescriptor(title: .actionOpenQueueTitle, systemImage: "list.bullet")
    static let cancelSession = ActionDescriptor(title: .actionCancelSessionTitle, systemImage: "xmark", role: .destructive)
    static let finishSession = ActionDescriptor(title: .actionFinishSessionTitle, systemImage: "flag.pattern.checkered")
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
