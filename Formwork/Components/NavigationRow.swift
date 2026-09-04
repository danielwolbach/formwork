//
//  NavigableRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct NavigationRow<Value: Hashable, Content: View>: View {
    let value: Value
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationLink(value: value) {
            HStack {
                content()
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .padding(8)
    }
}
