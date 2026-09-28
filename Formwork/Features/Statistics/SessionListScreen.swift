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
        ScrollView {
            NavigationRows(for: sessions) { session in
                DisplayableRow(session)
            }
        }
        .navigationTitle(.placeholder)
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
