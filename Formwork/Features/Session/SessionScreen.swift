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
    let session: Session

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var deleteAlert = false

    var body: some View {
        ScrollView {
            SessionRecap(session: session)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu(.more) {
                    Section {
                        if session.endedRecently {
                            SessionShareLink(session: session)
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
        .alert(.alertSessionDeleteTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertSessionDeleteMessage)
        }
    }

    private func delete() {
        modelContext.delete(session)
        dismiss()
    }
}

#Preview {
    let sessions = (try? Samples.container.mainContext.fetch(Session.finishedDescriptor)) ?? []

    NavigationStack {
        if let session = sessions.first {
            SessionScreen(session: session)
        }
    }
    .sampleData()
}
