//
//  ReadingCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ReadingCard: View {
    private let pictogram: Pictogram

    private let title: String

    private let reading: Reading?

    private let direction: Direction?

    @Environment(\.units)
    private var units: Units

    init<I: Indicator>(_ indicator: I) {
        self.init(pictogram: I.pictogram, title: I.title, reading: indicator.reading)
    }

    init(_ kind: StatisticKind, reading: Reading?, direction: Direction?) {
        self.init(pictogram: kind.statistic.pictogram, title: kind.statistic.title, reading: reading, direction: direction)
    }

    init<F: SessionFigure>(_ figure: F) {
        self.init(pictogram: F.pictogram, title: F.title, reading: figure.reading)
    }

    init<M: SessionMeasure>(_ comparison: SessionComparison<M>) {
        self.init(pictogram: M.pictogram, title: M.title, reading: comparison.current.reading, direction: comparison.direction)
    }

    private init(pictogram: Pictogram, title: String, reading: Reading?, direction: Direction? = nil) {
        self.pictogram = pictogram
        self.title = title
        self.reading = reading
        self.direction = direction
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: 0)

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Text(verbatim: reading?.formatted(.reading(units: units)) ?? "—")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                if let direction, direction != .flat {
                    Image(systemName: direction.image)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            GeometryReader { geometry in
                let side = min(geometry.size.height, geometry.size.width)

                Image(systemName: pictogram.image)
                    .font(.system(size: side))
                    .foregroundStyle(pictogram.color.secondary)
                    .offset(x: side * 0.25, y: -side * (1.0 / 3.0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .accessibilityHidden(true)
            }
        }
        .background(pictogram.color.quinary)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ReadingCard(StarterCatalog.Samples.weekStreak)
        .padding()
}
