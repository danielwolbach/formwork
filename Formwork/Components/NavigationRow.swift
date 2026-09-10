//
//  NavigationRow.swift
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

#Preview {
    NavigationStack {
        ScrollView {
            ForEach(Samples.exercises.prefix(6)) { exercise in
                NavigationRow(value: exercise) {
                    DisplayableRow(displayable: exercise)
                }
            }
        }
        .navigationDestination(for: Exercise.self) { exercise in
            DisplayableHero(displayable: exercise)
        }
    }
}
