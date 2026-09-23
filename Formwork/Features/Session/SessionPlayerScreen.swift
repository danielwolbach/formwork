//
//  SessionPlayerScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 21.09.26.
//

import FormworkKit
import SwiftUI

struct SessionPlayerScreen: View {
    let session: Session

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var finishAlert = false

    @State
    private var cancelAlert = false

    var body: some View {
        ZStack {
            if session.isActive {
                SessionPlayer(session: session) {
                    finishAlert = true
                }
                .transition(.blurReplace)
            } else {
                ScrollView {
                    SessionRecap(session: session)
                }
                .transition(.blurReplace)
            }
        }
        .toolbar {
            // Declared once and faded rather than moved between the branches below: the
            // principal item is the bar's own title view, so removing it makes the bar
            // re-lay-out that area on its own clock, out of step with the transition,
            // which causes a buggy toolbar transition. Might be fixed by a future
            // SwiftUI version.
            ToolbarItem(placement: .principal) {
                SessionStatus(session: session)
                    .opacity(session.isActive ? 1 : 0)
                    .accessibilityHidden(!session.isActive)
                    .animation(.smooth, value: session.isActive)
            }

            if session.isActive {
                ToolbarItem(placement: .topBarLeading) {
                    Button(.minimize) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu(.more) {
                        Section {
                            Button(.finishSession) {
                                finishAlert = true
                            }
                        }

                        Section {
                            Button(.discardSession) {
                                cancelAlert = true
                            }
                        }
                    }
                }
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    SessionShareLink(session: session)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm) {
                        dismiss()
                    }
                }
            }
        }
        .alert(.alertSessionFinishTitle, isPresented: $finishAlert) {
            Button(.finishSession) {
                finish()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertSessionFinishMessage)
        }
        .alert(.alertSessionCancelTitle, isPresented: $cancelAlert) {
            Button(.discardSession) {
                cancel()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertSessionCancelMessage)
        }
    }

    private func finish() {
        Haptics.notification(.success)

        withAnimation(.smooth) {
            session.finish()
        }
    }

    private func cancel() {
        session.cancel()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SessionPlayerScreen(session: Samples.sessions.first!)
    }
    .sampleData()
}
