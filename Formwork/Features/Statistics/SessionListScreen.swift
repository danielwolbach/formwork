//
//  SessionListScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import SwiftData
import SwiftUI

struct SessionListScreen: View {
    @Query(Session.finishedDescriptor) private var sessions: [Session]

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView {
                    Label(.emptySessionsTitle, systemImage: "flame")
                } description: {
                    Text(.emptySessionsMessage)
                }
            } else {
                ScreenStack {
                    ForEach(sessions.byMonth, id: \.month) { group in
                        SectionStack(title: Text(verbatim: group.month.monthDescription())) {
                            RowStack(navigating: group.sessions)
                        }
                    }
                }
            }
        }
        .navigationTitle(.screenSessionsTitle)
    }
}

private extension [Session] {
    var byMonth: [(month: Date, sessions: [Session])] {
        let calendar = Calendar.autoupdatingCurrent

        return Dictionary(grouping: self) { session in
            calendar.dateInterval(of: .month, for: session.started)?.start ?? session.started
        }
        .map { (month: $0.key, sessions: $0.value) }
        .sorted { $0.month > $1.month }
    }
}

#Preview {
    NavigationStack {
        SessionListScreen()
            .navigationDestination(for: Session.self) { session in
                SessionScreen(session: session)
            }
    }
    .sampleData()
}
