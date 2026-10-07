//
//  EasterEgg.swift
//  Formwork
//
//  Created by Daniel Wolbach on 01.10.26.
//

import SwiftUI

struct EasterEgg: View {
    private var times = 1.0

    @State
    private var degree = 0.0

    var body: some View {
        VStack(spacing: 20) {
            Button {
                withAnimation(.bouncy(duration: 2.5 * times)) {
                    degree += 360.0 * times
                }
            } label: {
                Image(systemName: "teddybear")
                    .font(.system(size: 70))
                    .rotationEffect(.degrees(degree))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    EasterEgg()
}
