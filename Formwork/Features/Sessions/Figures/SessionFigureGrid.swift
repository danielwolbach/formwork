//
//  SessionFigureGrid.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionFigureGrid: View {
    private let session: Session

    @Environment(\.statistics)
    private var statistics: Statistics

    @State
    private var selection: Quantity? = nil

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        TileGrid {
            ForEach(Quantity.figures) { quantity in
                SessionFigureCard(quantity, of: session, among: statistics.sessions) {
                    // A tap above an open sheet also reaches the tiles behind it, so it may only close the sheet.
                    guard selection == nil else {
                        return
                    }

                    selection = quantity
                }
            }
        }
        .sheet(item: $selection) { quantity in
            NavigationRoot {
                SessionFigureSheet(quantity, of: session, among: statistics.sessions)
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
