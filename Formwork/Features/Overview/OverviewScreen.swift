//
//  OverviewScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 19.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct OverviewScreen: View {
    @State
    private var sheet: Sheet? = nil

    var body: some View {
        ScrollView {
            ContentStack {
                StatisticChips()

                TodaySection()

                CalendarSection()
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .navigationTitle(.screenOverviewTitle)
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.settings) {
                        sheet = .settings
                    }
                }

                Section {
                    DebugMenu()
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }
}

#Preview {
    NavigationRoot {
        OverviewScreen()
    }
    .sampleData()
}
