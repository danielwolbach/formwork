//
//  SessionScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct SessionScreen: View {
    private let session: Session

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var deleteAlert = false

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        ScrollView {
            SessionRecap(session)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu(.more) {
                    Section {
                        if session.endedRecently {
                            SessionShareLink(session)
                        }
                    }

                    Section {
                        Button(.delete) {
                            deleteAlert = true
                        }
                    }
                }
            }
        }
        .alert(.placeholder, isPresented: $deleteAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.delete) {
                delete()
            }
        } message: {
            Text(.placeholder)
        }
    }

    private func delete() {
        context.delete(session)
        dismiss()
    }
}

#Preview {
    let sessions = (try? Samples.container.mainContext.fetch(Session.finishedDescriptor)) ?? []

    NavigationStack {
        if let session = sessions.first {
            SessionScreen(session)
        }
    }
    .sampleData()
}
