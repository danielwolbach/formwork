//
//  SessionFigureGrid.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct SessionFigureGrid: View {
    private let session: Session

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    @State
    private var selection: SessionFigureKind? = nil

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        TileGrid {
            ForEach(SessionFigureKind.allCases, id: \.self) { kind in
                SessionFigureCard(kind, of: session, among: sessions) {
                    // A tap above an open sheet also reaches the tiles behind it, so it may only close the sheet.
                    guard selection == nil else {
                        return
                    }

                    selection = kind
                }
            }
        }
        .sheet(item: $selection) { kind in
            NavigationRoot {
                SessionFigureSheet(kind, of: session, among: sessions)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ScrollView {
        ContentStack {
            SessionFigureGrid(Samples.sessions.first!)
        }
    }
    .sampleData()
}
