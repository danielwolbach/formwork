//
//  RowStack.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct RowStack<Item: Identifiable & Hashable, Row: View>: View {
    let items: [Item]
    @ViewBuilder let row: (Item) -> Row

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(items) { item in
                row(item)
            }
        }
        .padding(.horizontal, 8)
    }
}

extension RowStack where Item: SubtitledDisplayable, Row == NavigationRow<Item, DisplayableRow> {
    init(navigating items: [Item]) {
        self.init(items: items) { item in
            NavigationRow(value: item) {
                DisplayableRow(displayable: item)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            RowStack(navigating: Samples.exercises)
        }
    }
}
