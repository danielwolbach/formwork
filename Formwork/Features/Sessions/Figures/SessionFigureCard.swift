//
//  SessionFigureCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionFigureCard: View {
    private let kind: SessionFigureKind

    private let session: Session

    private let sessions: [Session]

    private let action: () -> Void

    init(_ kind: SessionFigureKind, of session: Session, among sessions: [Session], action: @escaping () -> Void) {
        self.kind = kind
        self.session = session
        self.sessions = sessions
        self.action = action
    }

    var body: some View {
        let comparison = SessionComparison(kind, of: session, among: sessions)

        if comparison.current != nil {
            Button(action: action) {
                ReadingCard(kind, reading: comparison.current, direction: comparison.direction)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    TileGrid {
        SessionFigureCard(.duration, of: Samples.sessions.first!, among: Samples.sessions) {}

        SessionFigureCard(.endTime, of: Samples.sessions.first!, among: Samples.sessions) {}
    }
    .padding()
    .sampleData()
}
