//
//  ValueRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkUI
import SwiftUI

struct ValueRow: View {
    private let title: String

    private let value: String?

    private let footnote: String?

    init(title: String, value: String? = nil, footnote: String? = nil) {
        self.title = title
        self.value = value
        self.footnote = footnote
    }

    var body: some View {
        LabeledContent {
            Text(verbatim: value ?? "—")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        } label: {
            Text(title)
                .font(.headline)

            if let footnote {
                Text(footnote)
            }
        }
        .labeledContentStyle(.row)
    }
}
