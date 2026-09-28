//
//  YearSection.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
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

        SectionView(String(year)) {
            content(year)
                .padding()
                .card()
                .padding(.horizontal)
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
