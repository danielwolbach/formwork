//
//  Action.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 04.09.26.
//

import AppIntents
import SwiftUI

public struct Action: Sendable {
    public let title: LocalizedStringResource

    public let image: String

    public let role: ButtonRole?

    public init(title: LocalizedStringResource, image: String, role: ButtonRole? = nil) {
        self.title = title
        self.image = image
        self.role = role
    }
}

extension Action {
    // MARK: - General

    public static let confirm = Action(title: .actionConfirmTitle, image: "checkmark", role: .confirm)

    public static let cancel = Action(title: .actionCancelTitle, image: "xmark", role: .cancel)

    public static let edit = Action(title: .actionEditTitle, image: "pencil")

    public static let archive = Action(title: .actionArchiveTitle, image: "archivebox")

    public static let unarchive = Action(title: .actionUnarchiveTitle, image: "tray.and.arrow.up")

    public static let delete = Action(title: .actionDeleteTitle, image: "trash", role: .destructive)

    public static let deselectAll = Action(title: .actionDeselectAllTitle, image: "xmark.circle")

    public static let remove = Action(title: .actionRemoveTitle, image: "minus.circle", role: .destructive)

    public static let more = Action(title: .actionMoreTitle, image: "ellipsis")

    public static let sort = Action(title: .actionSortTitle, image: "line.3.horizontal.decrease")

    public static let increase = Action(title: .actionIncreaseTitle, image: "plus")

    public static let decrease = Action(title: .actionDecreaseTitle, image: "minus")

    public static let backward = Action(title: .actionBackwardTitle, image: "chevron.backward")

    public static let forward = Action(title: .actionForwardTitle, image: "chevron.forward")

    public static let `continue` = Action(title: .actionContinueTitle, image: "chevron.forward")

    public static let retry = Action(title: .actionRetryTitle, image: "arrow.clockwise")

    public static let minimize = Action(title: .actionMinimizeTitle, image: "chevron.down")

    public static let share = Action(title: .actionShareTitle, image: "square.and.arrow.up")

    public static let viewAll = Action(title: .actionViewAllTitle, image: "list.bullet")

    public static let viewStatistics = Action(title: .actionViewStatisticsTitle, image: "chart.pie")

    public static let today = Action(title: .actionTodayTitle, image: "calendar.day")

    public static let debug = Action(title: .actionDebugTitle, image: "ladybug")

    public static let viewMode = Action(title: .actionViewModeTitle, image: "calendar.day.timeline.left")

    public static let settings = Action(title: .actionSettingsTitle, image: "gear")

    public static let unlockFullVersion = Action(title: .actionUnlockFullVersionTitle, image: "lock.open.fill")

    public static let discardChanges = Action(title: .actionDiscardChangesTitle, image: "trash", role: .destructive)

    public static let keepEditing = Action(title: .actionKeepEditingTitle, image: "pencil", role: .cancel)

    public static let openSettings = Action(title: .actionOpenSettingsTitle, image: "gear")

    public static let connectToHealth = Action(title: .actionConnectToHealthTitle, image: "heart")

    // MARK: - Exercise

    public static let createExercise = Action(title: .actionCreateExerciseTitle, image: "plus")

    public static let scanQRCode = Action(title: .actionScanQRCodeTitle, image: "qrcode.viewfinder")

    public static let guide = Action(title: .actionGuideTitle, image: "info.circle")

    public static let addToWorkout = Action(title: .actionAddToWorkoutTitle, image: "text.badge.plus")

    // MARK: - Workout

    public static let createWorkout = Action(title: .actionCreateWorkoutTitle, image: "plus")

    public static let addExercises = Action(title: .actionAddExercisesTitle, image: "text.badge.plus")

    public static let startSession = Action(title: .actionStartSessionTitle, image: "play.fill")

    // MARK: - Session

    public static let resumeSession = Action(title: .actionResumeSessionTitle, image: "play.fill")

    public static let replaceSession = Action(title: .actionReplaceSessionTitle, image: "arrow.trianglehead.2.clockwise", role: .destructive)

    public static let finishSession = Action(title: .actionFinishSessionTitle, image: "flag.pattern.checkered")

    public static let discardSession = Action(title: .actionDiscardSessionTitle, image: "xmark", role: .destructive)

    public static let complete = Action(title: .actionCompleteTitle, image: "checkmark")

    public static let skip = Action(title: .actionSkipTitle, image: "arrowtriangle.forward")

    public static let undo = Action(title: .actionUndoTitle, image: "arrow.uturn.backward")

    public static let queue = Action(title: .actionQueueTitle, image: "line.3.horizontal.decrease")

    public static let viewWorkout = Action(title: .actionViewWorkoutTitle, image: "clipboard")
}

extension Label where Title == Text, Icon == Image {
    public init(_ descriptor: Action) {
        self.init(descriptor.title, systemImage: descriptor.image)
    }
}

extension Button where Label == SwiftUI.Label<Text, Image> {
    public init(_ descriptor: Action, action: @escaping () -> Void) {
        self.init(descriptor.title, systemImage: descriptor.image, role: descriptor.role, action: action)
    }

    public init(_ descriptor: Action, intent: some AppIntent) {
        self.init(role: descriptor.role, intent: intent) {
            SwiftUI.Label(descriptor)
        }
    }
}

extension Toggle where Label == SwiftUI.Label<Text, Image> {
    public init(_ descriptor: Action, isOn: Binding<Bool>) {
        self.init(isOn: isOn) {
            SwiftUI.Label(descriptor)
        }
    }
}

extension Menu where Label == SwiftUI.Label<Text, Image> {
    public init(_ descriptor: Action, @ViewBuilder content: () -> Content) {
        self.init(descriptor.title, systemImage: descriptor.image, content: content)
    }
}
