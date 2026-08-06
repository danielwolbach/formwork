//
//  IconBadge.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct IconBadge: View {
    let icon: String
    let color: Color
    let size: CGFloat

    init(icon: String, color: Color = .accentColor, size: CGFloat = 64) {
        self.icon = icon
        self.color = color
        self.size = size
    }

    var body: some View {
        Image(systemName: icon)
            .font(iconFont)
            .frame(width: size, height: size)
            .foregroundStyle(color)
            .background(color.quinary)
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
    }

    private var cornerRadius: CGFloat {
        2 * size.squareRoot()
    }

    private var iconFont: Font {
        .system(size: size * 0.375)
    }
}

#Preview {
    ForEach([32, 64, 128, 256].map(CGFloat.init), id: \.self) { size in
        IconBadge(icon: "sparkles", size: size)
    }
}
