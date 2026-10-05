//
//  YearSection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct YearSection<Content: View>: View {
    private let years: ClosedRange<Int>

    @ViewBuilder
    private let content: (Int) -> Content

    @State
    private var selection: Int?

    init(years: ClosedRange<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.years = years
        self.content = content
    }

    var body: some View {
        let year = selection ?? years.upperBound

        SectionView(.fieldHistoryTitle, subtitle: String(year)) {
            GroupBox {
                ZStack(alignment: .top) {
                    content(year)
                        .id(year)
                        .transition(.blurReplace)
                }
            }
            .groupBoxStyle(.card)
            .animation(.snappy, value: year)
            .sensoryFeedback(.selection, trigger: year)
        } accessory: {
            Button(.backward) {
                selection = year - 1
            }
            .tint(nil)
            .disabled(year <= years.lowerBound)

            Button(.forward) {
                selection = year + 1
            }
            .tint(nil)
            .disabled(year >= years.upperBound)
        }
        .labelStyle(.fixedIconOnly)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }
}

#Preview {
    let history = History(.all, among: Samples.sessions)

    ScrollView {
        ContentStack {
            YearSection(years: history.years) { year in
                ActiveDaysYear(ActiveDays(history.year(year)))
            }
        }
    }
    .sampleData()
}
