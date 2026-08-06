//
//  SessionEntry+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

@MainActor
extension SessionEntry {
    var title: String {
        exercise.title
    }

    var subtitle: String {
        target.title
    }

    var color: Color {
        status == .pending ? exercise.color : status.color
    }

    var icon: String {
        status == .pending ? exercise.icon : status.icon
    }
}

extension SessionEntry.Status {
    var title: LocalizedStringResource {
        switch self {
        case .pending: .sessionEntryStatusPending
        case .skipped: .sessionEntryStatusSkipped
        case .done: .sessionEntryStatusDone
        }
    }

    var color: Color {
        switch self {
        case .pending: .secondary
        case .skipped: .orange
        case .done: .green
        }
    }

    var icon: String {
        switch self {
        case .pending: "circle"
        case .skipped: "arrow.turn.up.right"
        case .done: "checkmark"
        }
    }
}
