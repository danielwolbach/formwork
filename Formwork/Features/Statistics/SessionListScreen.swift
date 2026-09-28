//
//  SessionListScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct SessionListScreen: View {
    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView {
                    Label(.emptySessionsTitle, systemImage: "calendar")
                } description: {
                    Text(.emptySessionsMessage)
                }
            } else {
                ScrollView {
                    NavigationRows(for: sessions) { session in
                        DisplayableRow(session)
                    }
                }
            }
        }
        .navigationTitle(.screenSessionsTitle)
    }
}

#Preview {
    NavigationStack {
        SessionListScreen()
            .navigationDestination(for: Session.self) { session in
                SessionScreen(session)
            }
    }
    .sampleData()
}
