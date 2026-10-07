//
//  PictogramView.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

public struct PictogramView: View {
    private let pictogram: Pictogram

    private let badge: Pictogram?

    public init(_ pictogram: Pictogram, badge: Pictogram? = nil) {
        self.pictogram = pictogram
        self.badge = badge
    }

    public var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let symbolSize = side / 3

            ZStack {
                RoundedRectangle(cornerRadius: 2 * side.squareRoot(), style: .continuous)
                    .fill(pictogram.color.quinary)

                Image(systemName: pictogram.image)
                    .font(.system(size: symbolSize))
                    .fontWeight(.medium)
                    .foregroundStyle(pictogram.color)
            }
            .frame(width: side, height: side)
            .overlay(alignment: .bottomTrailing) {
                if let badge {
                    Image(systemName: badge.image)
                        .font(.system(size: symbolSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, badge.color)
                        .offset(x: symbolSize * 0.25, y: symbolSize * 0.25)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview {
    PictogramView(.init(image: "trophy", tint: .yellow), badge: .init(image: "checkmark.circle.fill", tint: .green))
        .padding(64)
}
