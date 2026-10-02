//
//  SessionEndTimeDetails.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionEndTimeDetails: View {
    private let session: Session

    private let sessions: [Session]

    init(_ session: Session, among sessions: [Session]) {
        self.session = session
        self.sessions = sessions
    }

    var body: some View {
        GroupBox {
            ValueComparison(SessionComparison<SessionEndTime>(session, among: sessions))
        }
        .groupBoxStyle(.card)
    }
}

#Preview {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                SessionFigureSheet(.endTime, of: Samples.sessions.first!, among: Samples.sessions)
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}
