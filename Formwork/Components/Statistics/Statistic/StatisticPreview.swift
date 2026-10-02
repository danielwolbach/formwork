//
//  StatisticPreview.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

/// Owns its query, so a row only fetches sessions once its context menu preview shows.
struct StatisticPreview: View {
    private let subject: History.Subject

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    init(_ subject: History.Subject) {
        self.subject = subject
    }

    var body: some View {
        let history = History(subject, among: sessions)

        if !history.sessions.isEmpty {
            StatisticGrid(history, includesCharts: false)
        }
    }
}

#Preview {
    ContentStack {
        StatisticPreview(.exercise(Samples.exercises[2]))
    }
    .frame(width: 360)
    .padding(.vertical)
    .sampleData()
}
