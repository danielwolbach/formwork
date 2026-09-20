//
//  SessionListScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

/// Every finished session.
struct SessionListScreen: View {
    @Query(Session.finishedDescriptor) private var sessions: [Session]

    var body: some View {
        ScrollView {
            NavigationList(sessions) { session in
                PictogramRow(session)
            }
        }
        .navigationTitle(.screenSessionsTitle)
    }
}

#Preview {
    NavigationStack {
        SessionListScreen()
            // Whichever screen pushes this one declares the destination, so the preview stands in for it.
            .navigationDestination(for: Session.self) { session in
                SessionScreen(session: session)
            }
    }
    .sampleData()
}
