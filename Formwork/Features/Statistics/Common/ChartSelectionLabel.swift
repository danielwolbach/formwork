//
//  ChartSelectionLabel.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.10.26.
//

import SwiftUI

struct ChartSelectionLabel: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(verbatim: text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(.tint)
            .background {
                // Opaque underneath, so the rule and marks don't show through the tint.
                Capsule()
                    .fill(Color(.systemBackground))

                Capsule()
                    .fill(.tint.quinary)
            }
    }
}
