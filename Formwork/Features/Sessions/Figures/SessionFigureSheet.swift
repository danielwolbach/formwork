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
        let definition = kind.definition
        let comparison = SessionComparison(kind, of: session, among: sessions)
        let points = comparison.points()

        DetailSheet(definition.pictogram, title: definition.title, subtitle: session.title, info: definition.info) {
            GroupBox {
                ValueComparison(comparison)
            }
            .groupBoxStyle(.card)

            if points.count > 1 {
                SectionView(.fieldLatestTitle, subtitle: String(localized: .fieldLastSessionsSubtitle(count: points.count))) {
                    GroupBox {
                        SessionsChart(points, title: definition.title, reading: kind.reading(of:))
                    }
                    .groupBoxStyle(.card)
                }
            }
        }
    }
}

#Preview("Measure") {
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                SessionFigureSheet(.volume, of: Samples.sessions.first!, among: Samples.sessions)
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Clock") {
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                SessionFigureSheet(.endTime, of: Samples.sessions.first!, among: Samples.sessions)
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}
