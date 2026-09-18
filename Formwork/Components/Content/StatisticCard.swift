//
//  StatisticCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//

import FormworkKit
import SwiftUI

struct StatisticCard: View {
    let title: String
    let value: String?
    let pictogram: Pictogram

    init(title: String, value: String?, pictogram: Pictogram) {
        self.title = title
        self.value = value
        self.pictogram = pictogram
    }

    init(_ statistic: some Displayable) {
        self.init(title: statistic.title, value: statistic.subtitle, pictogram: statistic.pictogram)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Spacer(minLength: 0)

            Text(title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)

            Text(verbatim: value ?? "—")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            GeometryReader { geometry in
                let side = geometry.size.height

                Image(systemName: pictogram.image)
                    .font(.system(size: side))
                    .foregroundStyle(pictogram.color.secondary)
                    .offset(x: side * 0.25, y: -side * (1.0 / 3.0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .aspectRatio(1.8, contentMode: .fit)
        .background(pictogram.tint.color.quinary)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    StatisticCard(title: "Streak", value: "42", pictogram: .streak)
        .padding()
}
