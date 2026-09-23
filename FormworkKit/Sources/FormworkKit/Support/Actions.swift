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

extension ActionDescriptor {
    public static let create = ActionDescriptor(title: .actionCreateTitle, systemImage: "plus")

    public static let confirm = ActionDescriptor(title: .actionConfirmTitle, systemImage: "checkmark", role: .confirm)

    public static let cancel = ActionDescriptor(title: .actionCancelTitle, systemImage: "xmark", role: .cancel)

    public static let edit = ActionDescriptor(title: .actionEditTitle, systemImage: "pencil")

    public static let delete = ActionDescriptor(title: .actionDeleteTitle, systemImage: "trash", role: .destructive)

    public static let more = ActionDescriptor(title: .actionMoreTitle, systemImage: "ellipsis")

    public static let remove = ActionDescriptor(title: .actionRemoveTitle, systemImage: "minus.circle", role: .destructive)

    public static let increase = ActionDescriptor(title: .actionIncreaseTitle, systemImage: "plus")

    public static let decrease = ActionDescriptor(title: .actionDecreaseTitle, systemImage: "minus")

    public static let unit = ActionDescriptor(title: .actionUnitTitle, systemImage: "base.unit")

    public static let forward = ActionDescriptor(title: .actionForwardTitle, systemImage: "chevron.forward")

    public static let backward = ActionDescriptor(title: .actionBackwardTitle, systemImage: "chevron.backward")

    public static let complete = ActionDescriptor(title: .actionCompleteTitle, systemImage: "checkmark")

    public static let coninue = ActionDescriptor(title: .actionContinueTitle, systemImage: "chevron.forward")

    public static let undo = ActionDescriptor(title: .actionUndoTitle, systemImage: "arrow.uturn.backward")

    public static let minimize = ActionDescriptor(title: .actionMinimizeTitle, systemImage: "chevron.down")

    public static let select = ActionDescriptor(title: .actionSelectTitle, systemImage: "plus")

    public static let skip = ActionDescriptor(title: .actionSkipTitle, systemImage: "arrowtriangle.forward")

    public static let share = ActionDescriptor(title: .actionShareTitle, systemImage: "square.and.arrow.up")

    public static let viewAll = ActionDescriptor(title: .actionViewAllTitle, systemImage: "list.bullet")

    public static let debug = ActionDescriptor(title: .actionDebugTitle, systemImage: "ladybug")

    // Workout

    public static let startSession = ActionDescriptor(title: .actionStartSessionTitle, systemImage: "play.fill")

    public static let replaceSession = ActionDescriptor(title: .actionReplaceSessionTitle, systemImage: "arrow.trianglehead.2.clockwise", role: .destructive)

    public static let resumeSession = ActionDescriptor(title: .actionResumeSessionTitle, systemImage: "play.fill")

    public static let addExercise = ActionDescriptor(title: .actionAddExerciseTitle, systemImage: "text.badge.plus")

    public static let viewStatistics = ActionDescriptor(title: .actionViewStatsTitle, systemImage: "chart.pie")

    // Session

    public static let discardSession = ActionDescriptor(title: .actionCancelSessionTitle, systemImage: "xmark", role: .destructive)

    public static let finishSession = ActionDescriptor(title: .actionFinishSessionTitle, systemImage: "flag.pattern.checkered")
}

extension Label where Title == Text, Icon == Image {
    public init(_ descriptor: ActionDescriptor) {
        self.init(descriptor.title, systemImage: descriptor.systemImage)
    }
}

extension Button where Label == SwiftUI.Label<Text, Image> {
    public init(_ descriptor: ActionDescriptor, action: @escaping () -> Void) {
        self.init(
            descriptor.title,
            systemImage: descriptor.systemImage,
            role: descriptor.role,
            action: action
        )
    }
}

extension Button where Label == SwiftUI.Label<Text, Image> {
    public init(_ descriptor: ActionDescriptor, intent: some AppIntent) {
        self.init(intent: intent) {
            SwiftUI.Label {
                Text(descriptor.title)
            } icon: {
                Image(systemName: descriptor.systemImage)
            }
        }
    }
}

extension Toggle where Label == SwiftUI.Label<Text, Image> {
    public init(_ descriptor: ActionDescriptor, isOn: Binding<Bool>) {
        self.init(isOn: isOn) {
            SwiftUI.Label {
                Text(descriptor.title)
            } icon: {
                Image(systemName: descriptor.systemImage)
            }
        }
    }
}

extension Menu where Label == SwiftUI.Label<Text, Image> {
    public init(_ descriptor: ActionDescriptor, @ViewBuilder content: () -> Content) {
        self.init(
            descriptor.title,
            systemImage: descriptor.systemImage,
            content: content
        )
    }
}
