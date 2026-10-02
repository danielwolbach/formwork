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
        Button(action: action) {
            label
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var label: some View {
        switch kind {
        case .duration: card(SessionDuration.self)
        case .endTime: ReadingCard(SessionEndTime(session))
        case .skipRate: card(SessionSkipRate.self)
        case .exerciseDuration: card(SessionExerciseDuration.self)
        case .completedExercises: card(SessionCompletedExercises.self)
        case .volume: card(SessionVolume.self)
        }
    }

    private func card<M: SessionMeasure>(_: M.Type) -> some View {
        ReadingCard(SessionComparison<M>(session, among: sessions))
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
