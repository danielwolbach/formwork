//
//  SessionList.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct SessionList: View {
    let sessions: [Session]

    var body: some View {
        RowStack {
            ForEach(sessions) { session in
                IconNavigationRow(
                    value: session,
                    icon: "checkmark.circle",
                    color: .green,
                    title: session.workout?.name ?? "",
                    subtitle: subtitle(for: session)
                )
            }
        }
    }

    private func subtitle(for session: Session) -> String {
        let date = session.ended?.formatted(date: .abbreviated, time: .shortened) ?? ""
        guard let duration = session.duration else {
            return date
        }

        return "\(date) · \(duration.formatted(.time(pattern: .hourMinute(padHourToLength: 1))))"
    }
}

#Preview {
    NavigationStack {
        SessionList(sessions: Session.samples)
            .navigationDestination(for: Session.self) { session in
                SessionDetailScreen(session: session)
            }
    }
    .sampleData()
}
