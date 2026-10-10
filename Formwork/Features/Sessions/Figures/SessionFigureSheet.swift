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
    private let quantity: Quantity

    private let session: Session

    private let sessions: [Session]

    init(_ quantity: Quantity, of session: Session, among sessions: [Session]) {
        self.quantity = quantity
        self.session = session
        self.sessions = sessions
    }

    var body: some View {
        DetailSheet(quantity, subtitle: session.title) {
            GroupBox {
                ValueComparison(Comparison(quantity, of: session, among: sessions), of: session)
            }
            .groupBoxStyle(.card)

            if let series = Series(quantity, endingWith: session, among: sessions), series.points.count > 1 {
                SectionView(.fieldLatestTitle, subtitle: String(localized: .fieldLastSessionsSubtitle(count: series.points.count))) {
                    GroupBox {
                        SessionsChart(series, title: quantity.title)
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
