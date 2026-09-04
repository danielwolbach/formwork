//
//  PictogramView.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct PictogramView: View {
    let pictogram: Pictogram
    let size: CGFloat
    let cornerRadius: CGFloat
    
    init(pictogram: Pictogram, size: CGFloat, cornerRadius: CGFloat? = nil) {
        self.pictogram = pictogram
        self.size = size
        self.cornerRadius = cornerRadius ?? 2 * size.squareRoot()
    }
    
    var body: some View {
            Image(systemName: pictogram.icon)
                .font(.system(size: size * 0.33))
                .frame(width: size, height: size)
                .foregroundStyle(pictogram.color)
                .background(pictogram.color.quaternary)
                .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
    }
}
