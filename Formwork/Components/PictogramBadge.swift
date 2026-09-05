//
//  PictogramBadge.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

struct PictogramBadge: View {
    let pictogram: Pictogram
    let size: CGFloat
    
    var body: some View {
        Image(systemName: pictogram.icon)
            .font(.system(size: size))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.background, pictogram.color)
    }
}

#Preview {
    HStack(spacing: 32) {
        PictogramView(pictogram: Pictogram(icon: "dumbbell", color: .indigo), size: 96)
            .overlay(alignment: .bottomTrailing) {
                PictogramBadge(pictogram: Pictogram(icon: "checkmark.circle.fill", color: .green), size: 32)
                    .offset(x: 8, y: 8)
            }
        
        PictogramView(pictogram: Pictogram(icon: "figure.run", color: .pink), size: 96)
            .overlay(alignment: .bottomTrailing) {
                PictogramBadge(pictogram: Pictogram(icon: "forward.end.circle.fill", color: .orange), size: 32)
                    .offset(x: 8, y: 8)
            }
    }
    .padding()
}
