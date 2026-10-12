//
//  EasterEgg.swift
//  Formwork
//
//  Created by Daniel Wolbach on 01.10.26.
//

import SwiftUI

struct EasterEgg: View {
    @State
    private var degree = 0.0

    var body: some View {
        Button {
            withAnimation(.bouncy(duration: 2.5)) {
                degree += 360
            }
        } label: {
            Image(systemName: "teddybear")
                .font(.system(size: 70))
                .rotationEffect(.degrees(degree))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EasterEgg()
}
