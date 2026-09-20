//
//  NavigationList.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftUI

struct NavigationList<Items: RandomAccessCollection, Row: View>: View where Items.Element: Identifiable & Hashable {
    private let items: Items
    private let row: (Items.Element) -> Row

    init(_ items: Items, @ViewBuilder row: @escaping (Items.Element) -> Row) {
        self.items = items
        self.row = row
    }

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    row(item)

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            NavigationList(Samples.exercises) { exercise in
                PictogramRow(exercise)
            }
        }
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseScreen(exercise: exercise)
        }
    }
    .sampleData()
}
