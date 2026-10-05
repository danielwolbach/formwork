//
//  ValueComparison.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ValueComparison: View {
    private struct Value {
        let title: String

        let reading: Reading?

        let footnote: String
    }

    private let before: Value?

    private let after: Value

    private let direction: Trend.Direction?

    init(recent: Reading?, before: Reading?, direction: Trend.Direction?) {
        let before = Value(
            title: String(localized: .fieldBeforeTitle),
            reading: before,
            footnote: String(localized: .fieldPreviousWeeksSubtitle(count: History.baselineWeeks))
        )

        self.init(before: before, after: Self.recent(recent), direction: direction)
    }

    init(recent: Reading?) {
        self.init(before: nil, after: Self.recent(recent), direction: nil)
    }

    init(_ comparison: SessionComparison) {
        let session = comparison.session
        let before = Value(
            title: String(localized: .fieldBeforeTitle),
            reading: comparison.baseline,
            footnote: String(localized: .fieldPreviousWeeksSubtitle(count: History.recentWeeks))
        )
        let after = Value(
            title: String(localized: .fieldThisSessionTitle),
            reading: comparison.current,
            footnote: session.startDate.formatted(session.localCalendar(from: .current).formatStyle(date: .abbreviated))
        )

        self.init(before: before, after: after, direction: comparison.direction)
    }

    private init(before: Value?, after: Value, direction: Trend.Direction?) {
        self.before = before
        self.after = after
        self.direction = direction
    }

    var body: some View {
        if let before, let direction {
            HStack(spacing: .items) {
                ValueColumn(title: before.title, reading: before.reading, footnote: before.footnote)

                Image(systemName: direction.image)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.tint)
                    .frame(maxWidth: .infinity)

                ValueColumn(title: after.title, reading: after.reading, footnote: after.footnote)
            }
        } else {
            VStack(spacing: .groups) {
                ValueRow(title: after.title, reading: after.reading, footnote: after.footnote)

                if let before {
                    Divider()

                    ValueRow(title: before.title, reading: before.reading, footnote: before.footnote)
                }
            }
        }
    }

    private static func recent(_ reading: Reading?) -> Value {
        Value(
            title: String(localized: .fieldRecentTitle),
            reading: reading,
            footnote: String(localized: .fieldLastWeeksSubtitle(count: History.recentWeeks))
        )
    }
}

#Preview {
    let comparison = SessionComparison(.duration, of: Samples.sessions.first!, among: Samples.sessions)

    VStack {
        GroupBox {
            ValueComparison(recent: .rate(2.8), before: .rate(2.1), direction: .up)
        }

        GroupBox {
            ValueComparison(recent: .rate(2.8), before: nil, direction: nil)
        }

        GroupBox {
            ValueComparison(comparison)
        }

        GroupBox {
            ValueComparison(recent: .count(12))
        }
    }
    .groupBoxStyle(.card)
    .padding()
    .sampleData()
}
