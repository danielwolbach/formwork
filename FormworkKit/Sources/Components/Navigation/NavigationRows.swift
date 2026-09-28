//
//  NavigationRows.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import SwiftUI

public struct NavigationRows<Data: RandomAccessCollection, Row: View>: View
    where Data.Element: Identifiable & Hashable
{
    private let data: Data

    @ViewBuilder
    private let row: (Data.Element) -> Row

    public init(for data: Data, @ViewBuilder row: @escaping (Data.Element) -> Row) {
        self.data = data
        self.row = row
    }

    public var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(data) { element in
                NavigationLink(value: element) {
                    // Inset inside the link, so the whole width and the gaps between rows are tappable.
                    HStack {
                        row(element)

                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
