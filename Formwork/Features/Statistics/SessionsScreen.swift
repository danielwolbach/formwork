//
//  SessionsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import SwiftData
import SwiftUI

struct SessionsScreen: View {
    @Query(Session.finishedDescriptor) private var sessions: [Session]

    var body: some View {
        ScreenStack {
            ForEach(sessions.groupedByMonth(), id: \.month) { group in
                SectionStack(title: Text(verbatim: group.month.monthDescription())) {
                    RowStack(navigating: group.sessions)
                }
            }
        }
        .navigationTitle(.screenSessionsTitle)
    }
}

#Preview {
    NavigationStack {
        SessionsScreen()
            .navigationDestination(for: Session.self) { session in
                SessionScreen(session: session)
            }
    }
    .sampleData()
}
