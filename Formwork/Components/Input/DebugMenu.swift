//
//  DebugMenu.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct DebugMenu: View {
    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @AppStorage(StorageKeys.onboardingPending)
    private var onboardingPending: Bool = true

    var body: some View {
        #if DEBUG
            Menu(.debug) {
                Button {
                    onboardingPending = true
                } label: {
                    VerbatimLabel(verbatim: "Restart Onboarding", systemImage: "arrow.counterclockwise")
                }

                Button(role: .destructive) {
                    Storage.deleteEverything(in: modelContext)
                } label: {
                    VerbatimLabel(verbatim: "Delete Everything", systemImage: "trash")
                }
            }
        #else
            EmptyView()
        #endif
    }
}

private struct VerbatimLabel: View {
    let verbatim: String

    let systemImage: String

    var body: some View {
        Label {
            Text(verbatim: verbatim)
        } icon: {
            Image(systemName: systemImage)
        }
    }
}
