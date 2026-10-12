//
//  SessionStatus.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionStatus: View {
    private let session: Session

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        VStack(spacing: 2) {
            if let workout = session.workout {
                Text(workout.title)
                    .lineLimit(1)
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            HStack {
                Text(verbatim: "\(session.resolvedCount) / \((session.entries ?? []).count)")
                    .contentTransition(.numericText(value: Double(session.resolvedCount)))
                    .accessibilityLabel(Text(.sessionProgressLabel(resolved: session.resolvedCount, total: (session.entries ?? []).count)))

                Divider()
                    .frame(height: 12)

                SessionElapsedTime(session)
            }
            .font(.caption2)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    NavigationRoot {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SessionStatus(Samples.activeSession)
                }
            }
    }
    .sampleData()
}
