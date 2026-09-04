//
//  NavigableList.swift
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

#Preview {
    NavigationStack {
        RowStack(items: Samples.exercises) { exercise in
            NavigationRow(value: exercise) {
                DisplayableRow(displayable: exercise)
            }
        }
    }
}
