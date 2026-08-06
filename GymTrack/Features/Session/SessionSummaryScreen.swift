//
//  SessionSummaryScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct SessionSummaryScreen: View {
    let session: Session
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            ScreenStack {
                IconHero(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: session.workout?.name ?? String(localized: .screenStats),
                    subtitle: session.ended?.formatted(date: .abbreviated, time: .shortened) ?? ""
                )

                SessionStatistics(session: session)
            }
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.actionDone, action: onDone)
            }
        }
    }
}
