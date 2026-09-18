//
//  Actions.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import AppIntents
import SwiftUI

public struct ActionDescriptor: Sendable {
    public let title: LocalizedStringResource
    public let systemImage: String
    public let role: ButtonRole?

    public init(title: LocalizedStringResource, systemImage: String, role: ButtonRole? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
    }
}

public extension ActionDescriptor {
    static let create = ActionDescriptor(title: .actionCreateTitle, systemImage: "plus")
    static let confirm = ActionDescriptor(title: .actionConfirmTitle, systemImage: "checkmark", role: .confirm)
    static let cancel = ActionDescriptor(title: .actionCancelTitle, systemImage: "xmark", role: .cancel)
    static let edit = ActionDescriptor(title: .actionEditTitle, systemImage: "pencil")
    static let delete = ActionDescriptor(title: .actionDeleteTitle, systemImage: "trash", role: .destructive)
    static let more = ActionDescriptor(title: .actionMoreTitle, systemImage: "ellipsis")
    static let remove = ActionDescriptor(title: .actionRemoveTitle, systemImage: "minus.circle", role: .destructive)
    static let increase = ActionDescriptor(title: .actionIncreaseTitle, systemImage: "plus")
    static let decrease = ActionDescriptor(title: .actionDecreaseTitle, systemImage: "minus")
    static let unit = ActionDescriptor(title: .actionUnitTitle, systemImage: "base.unit")
    static let forward = ActionDescriptor(title: .actionForwardTitle, systemImage: "chevron.forward")
    static let backward = ActionDescriptor(title: .actionBackwardTitle, systemImage: "chevron.backward")
    static let complete = ActionDescriptor(title: .actionCompleteTitle, systemImage: "checkmark")
    static let undo = ActionDescriptor(title: .actionUndoTitle, systemImage: "arrow.uturn.backward")
    static let minimize = ActionDescriptor(title: .actionMinimizeTitle, systemImage: "chevron.down")
    static let select = ActionDescriptor(title: .actionSelectTitle, systemImage: "plus")
    static let skip = ActionDescriptor(title: .actionSkipTitle, systemImage: "arrowtriangle.forward")

    // Workout
    static let startSession = ActionDescriptor(title: .actionStartSessionTitle, systemImage: "play.fill")
    static let replaceSession = ActionDescriptor(title: .actionReplaceSessionTitle, systemImage: "arrow.trianglehead.2.clockwise", role: .destructive)
    static let resumeSession = ActionDescriptor(title: .actionResumeSessionTitle, systemImage: "play.fill")
    static let addExercise = ActionDescriptor(title: .actionAddExerciseTitle, systemImage: "text.badge.plus")
    static let viewStatistics = ActionDescriptor(title: .actionViewStatsTitle, systemImage: "chart.pie")

    // Session
    static let discardSession = ActionDescriptor(title: .actionCancelSessionTitle, systemImage: "xmark", role: .destructive)
    static let finishSession = ActionDescriptor(title: .actionFinishSessionTitle, systemImage: "flag.pattern.checkered")
}

public extension Button where Label == SwiftUI.Label<Text, Image> {
    init(_ descriptor: ActionDescriptor, action: @escaping () -> Void) {
        self.init(
            descriptor.title,
            systemImage: descriptor.systemImage,
            role: descriptor.role,
            action: action
        )
    }
}

public extension Button where Label == SwiftUI.Label<Text, Image> {
    init(_ descriptor: ActionDescriptor, intent: some AppIntent) {
        self.init(intent: intent) {
            SwiftUI.Label {
                Text(descriptor.title)
            } icon: {
                Image(systemName: descriptor.systemImage)
            }
        }
    }
}

public extension Toggle where Label == SwiftUI.Label<Text, Image> {
    init(_ descriptor: ActionDescriptor, isOn: Binding<Bool>) {
        self.init(isOn: isOn) {
            SwiftUI.Label {
                Text(descriptor.title)
            } icon: {
                Image(systemName: descriptor.systemImage)
            }
        }
    }
}

public extension Menu where Label == SwiftUI.Label<Text, Image> {
    init(_ descriptor: ActionDescriptor, @ViewBuilder content: () -> Content) {
        self.init(
            descriptor.title,
            systemImage: descriptor.systemImage,
            content: content
        )
    }
}
