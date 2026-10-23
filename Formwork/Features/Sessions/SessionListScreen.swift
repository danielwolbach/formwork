//
//  SessionListScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct SessionListScreen: View {
    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    @State
    private var selection: Session.ID?

    @State
    private var detailIdentity = UUID()

    @State
    private var compactColumn: NavigationSplitViewColumn = .sidebar

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $compactColumn) {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView {
                        Label(.emptySessionsTitle, systemImage: "calendar")
                    } description: {
                        Text(.emptySessionsMessage)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(sessions) { session in
                                Button {
                                    select(session.id)
                                } label: {
                                    SessionRow(session, isSelected: isShownSelected(session.id))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .swipeActionsContainer()
                        .animation(.snappy, value: sessions.count)
                    }
                    .contentMargins(.bottom, .sections, for: .scrollContent)
                }
            }
            .navigationTitle(.screenSessionsTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(.cancel) {
                        dismiss()
                    }
                }
            }
        } detail: {
            ZStack {
                NavigationRoot {
                    if let id = selection, let session = sessions.first(where: { $0.id == id }) {
                        SessionScreen(session)
                    } else {
                        ContentUnavailableView(.emptySessionSelectionTitle, systemImage: "calendar")
                    }
                }
                // A fresh stack pops whatever was pushed, even when the same session is tapped again.
                .id(detailIdentity)
                .transition(.blurReplace)
            }
            .animation(.smooth, value: detailIdentity)
        }
    }

    /// A collapsed split view keeps the selection after going back, so it is only shown side by side with the detail.
    private func isShownSelected(_ session: Session.ID) -> Bool {
        horizontalSizeClass == .regular && selection == session
    }

    private func select(_ session: Session.ID) {
        selection = session
        detailIdentity = UUID()
        // Buttons don't drive a collapsed split view the way list selection does, so it has to be told to show the detail.
        compactColumn = .detail
    }
}

#Preview {
    SessionListScreen()
        .sampleData()
}
