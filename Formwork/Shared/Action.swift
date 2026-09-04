//
//  Action.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct Action {
    let title: LocalizedStringResource
    let systemImage: String
    let role: ButtonRole?

    init(title: LocalizedStringResource, systemImage: String, role: ButtonRole? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
    }
}

extension Action {
    static let placeholder = Action(title: .commonPlaceholderTitle, systemImage: "questionmark")
    static let delete = Action(title: .actionDeleteTitle, systemImage: "trash", role: .destructive)
    static let create = Action(title: .actionCreateTitle, systemImage: "plus")
    static let edit = Action(title: .actionEditTitle, systemImage: "pencil")
    static let confirm = Action(title: .actionConfirmTitle, systemImage: "checkmark", role: .confirm)
    static let cancel = Action(title: .actionCancelTitle, systemImage: "xmark", role: .cancel)
    static let more = Action(title: .actionMoreTitle, systemImage: "ellipsis")
    static let stats = Action(title: .actionStatsTitle, systemImage: "chart.pie")
    static let remove = Action(title: .actionRemoveTitle, systemImage: "minus.circle", role: .destructive)
    static let increase = Action(title: .actionIncreaseTitle, systemImage: "plus")
    static let decrease = Action(title: .actionDecreaseTitle, systemImage: "minus")
    
    // Workuot
    static let startSession = Action(title: .actionStartSessionTitle, systemImage: "play.fill")
    static let addExercise = Action(title: .actionAddExerciseTitle, systemImage: "text.badge.plus")
}

extension Button where Label == SwiftUI.Label<Text, Image> {
    init(_ descriptor: Action, action: @escaping () -> Void) {
        self.init(
            descriptor.title,
            systemImage: descriptor.systemImage,
            role: descriptor.role,
            action: action
        )
    }
}

extension Menu where Label == SwiftUI.Label<Text, Image> {
    init(_ descriptor: Action, @ViewBuilder content: () -> Content) {
        self.init(
            descriptor.title,
            systemImage: descriptor.systemImage,
            content: content
        )
    }
}
