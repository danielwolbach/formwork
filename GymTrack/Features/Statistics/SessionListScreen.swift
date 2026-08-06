//
//  SessionListScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct SessionListScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    let sessions: [Session]

    var body: some View {
        content
            .navigationTitle(.screenSessionHistory)
            .navigationDestination(for: Session.self) { session in
                SessionDetailScreen(session: session)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(.close) {
                        dismiss()
                    }
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if finishedSessions.isEmpty {
            ContentUnavailableView(.emptyStats, systemImage: "clock.arrow.circlepath")
        } else {
            ScrollView {
                SessionList(sessions: finishedSessions)
            }
        }
    }

    private var finishedSessions: [Session] {
        sessions.finishedSessions
    }
}
