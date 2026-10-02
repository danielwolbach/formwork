//
//  SessionFigureSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionFigureSheet: View {
    private let kind: SessionFigureKind

    private let session: Session

    private let sessions: [Session]

    init(_ kind: SessionFigureKind, of session: Session, among sessions: [Session]) {
        self.kind = kind
        self.session = session
        self.sessions = sessions
    }

    var body: some View {
        let figure = kind.figure

        DetailSheet(figure.pictogram, title: figure.title, subtitle: session.title, info: figure.info) {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        switch kind {
        case .duration: SessionMeasureDetails<SessionDuration>(session, among: sessions)
        case .endTime: SessionEndTimeDetails(session, among: sessions)
        case .skipRate: SessionMeasureDetails<SessionSkipRate>(session, among: sessions)
        case .exerciseDuration: SessionMeasureDetails<SessionExerciseDuration>(session, among: sessions)
        case .completedExercises: SessionMeasureDetails<SessionCompletedExercises>(session, among: sessions)
        case .volume: SessionMeasureDetails<SessionVolume>(session, among: sessions)
        }
    }
}

#Preview {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                SessionFigureSheet(.duration, of: Samples.sessions.first!, among: Samples.sessions)
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}
