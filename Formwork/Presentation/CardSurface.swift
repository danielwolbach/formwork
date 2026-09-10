//
//  CardSurface.swift
//  Formwork
//
//  Created by Daniel Wolbach on 09.09.26.
//

import SwiftUI

extension Shape where Self == RoundedRectangle {
    static var card: RoundedRectangle {
        .rect(cornerRadius: 16, style: .continuous)
    }
}

extension View {
    func cardFill(tint: Color) -> some View {
        background(tint.quinary)
            .background(.ultraThinMaterial)
    }

    func cardSurface() -> some View {
        clipShape(.card)
            .contentShape(.rect)
    }
}

#Preview {
    VStack(spacing: 16) {
        Text(verbatim: "Tinted")
            .frame(maxWidth: .infinity)
            .padding(32)
            .cardFill(tint: .indigo)
            .cardSurface()

        Text(verbatim: "Opaque")
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(.background)
            .cardSurface()
    }
    .padding()
}
