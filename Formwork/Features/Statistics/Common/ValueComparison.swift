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

    private let direction: Comparison.Direction?

    init(_ comparison: Comparison) {
        let before = Value(
            title: String(localized: .fieldBeforeTitle),
            reading: comparison.typical,
            footnote: String(localized: .fieldPreviousWeeksSubtitle(count: History.baselineWeeks))
        )

        self.init(before: before, after: Self.recent(comparison.current), direction: comparison.direction)
    }

    init(_ comparison: Comparison, latestOn date: Date?) {
        let before = Value(
            title: String(localized: .fieldBeforeTitle),
            reading: comparison.typical,
            footnote: String(localized: .fieldPreviousWeeksSubtitle(count: History.baselineWeeks))
        )
        let after = Value(
            title: String(localized: .fieldLatestTitle),
            reading: comparison.current,
            footnote: date?.formatted(date: .abbreviated, time: .omitted) ?? ""
        )

        self.init(before: before, after: after, direction: comparison.direction)
    }

    init(recent: Reading?) {
        self.init(before: nil, after: Self.recent(recent), direction: nil)
    }

    init(_ comparison: Comparison, of session: Session) {
        let before = Value(
            title: String(localized: .fieldBeforeTitle),
            reading: comparison.typical,
            footnote: String(localized: .fieldPreviousWeeksSubtitle(count: History.recentWeeks))
        )
        let after = Value(
            title: String(localized: .fieldThisSessionTitle),
            reading: comparison.current,
            footnote: session.startDate.formatted(session.localCalendar(from: .current).formatStyle(date: .abbreviated))
        )

        self.init(before: before, after: after, direction: comparison.direction)
    }

    private init(before: Value?, after: Value, direction: Comparison.Direction?) {
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
    let session = Samples.sessions.first!

    VStack {
        GroupBox {
            ValueComparison(Comparison(current: .rate(2.8), typical: .rate(2.1), direction: .up))
        }

        GroupBox {
            ValueComparison(Comparison(current: .rate(2.8), typical: nil, direction: nil))
        }

        GroupBox {
            ValueComparison(Comparison(.duration, of: session, among: Samples.sessions), of: session)
        }

        GroupBox {
            ValueComparison(recent: .count(12))
        }
    }
    .groupBoxStyle(.card)
    .padding()
    .sampleData()
}
