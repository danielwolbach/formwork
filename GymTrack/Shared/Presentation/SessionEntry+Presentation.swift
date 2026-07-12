//
//  SessionEntry+Presentation.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

extension SessionEntry {
    var systemImage: String {
        status == .pending ? exercise.systemImage : status.systemImage
    }
}

extension SessionEntry {
    var color: Color {
        status == .pending ? exercise.color : status.color
    }
}

extension SessionEntry {
    var subtitle: Text {
        switch status {
        case .pending:
            target.summary
        case .skipped:
            Text("Skipped · \(target.summary)")
        case .done:
            Text("Done · \(target.summary)")
        }
    }
}

extension SessionEntry.Status {
    var title: LocalizedStringKey {
        switch self {
        case .pending: "Pending"
        case .skipped: "Skipped"
        case .done: "Done"
        }
    }
}

extension SessionEntry.Status {
    var systemImage: String {
        switch self {
        case .pending: "circle"
        case .skipped: "arrow.turn.up.right"
        case .done: "checkmark"
        }
    }
}

extension SessionEntry.Status {
    var color: Color {
        switch self {
        case .pending: .secondary
        case .skipped: .orange
        case .done: .green
        }
    }
}
