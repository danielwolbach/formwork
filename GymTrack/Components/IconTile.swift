//
//  IconTile.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct IconTile: View {
    let systemImage: String
    let color: Color
    let size: Size

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size.fontSize))
            .foregroundStyle(color)
            .frame(width: size.size, height: size.size)
            .glassEffect(
                .regular.tint(color.opacity(0.2)),
                in: .rect(cornerRadius: size.cornerRadius, style: .continuous)
            )
            .background(.background, in: .rect(cornerRadius: size.cornerRadius))
    }
}

extension IconTile {
    enum Size {
        case regular
        case large

        var size: CGFloat {
            switch self {
            case .regular: 64
            case .large: 256
            }
        }

        var fontSize: CGFloat {
            0.375 * size
        }

        var cornerRadius: CGFloat {
            switch self {
            case .regular: 12
            case .large: 24
            }
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        IconTile(systemImage: "sparkles", color: .accentColor, size: .large)
        IconTile(systemImage: "sparkles", color: .accentColor, size: .regular)
    }
}
