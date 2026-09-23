//
//  PictogramView.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

@MainActor
public struct PictogramView: View {
    let pictogram: Pictogram

    let badge: Pictogram?

    public init(pictogram: Pictogram, badge: Pictogram? = nil) {
        self.pictogram = pictogram
        self.badge = badge
    }

    public var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)

            ZStack {
                RoundedRectangle(cornerRadius: 2 * side.squareRoot(), style: .continuous)
                    .fill(pictogram.color.quinary)

                Image(systemName: pictogram.image)
                    .font(.system(size: side * (1.0 / 3.0)))
                    .foregroundStyle(pictogram.color)
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomTrailing) {
                if let badge {
                    Image(systemName: badge.image)
                        .font(.system(size: side * (1.0 / 3.0)))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, badge.color)
                        .offset(x: side * (1.0 / 3.0) * 0.25, y: side * (1.0 / 3.0) * 0.25)
                }
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    PictogramView(pictogram: .record, badge: .completedBadge)
        .padding().padding()
}
