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

    private let direction: Direction?

    init(recent: Reading?, before: Reading?, direction: Direction?) {
        let before = Value(
            title: String(localized: .fieldBeforeTitle),
            reading: before,
            footnote: String(localized: .fieldBeforeSubtitle(days: History.baselineDays))
        )

        self.init(before: before, after: Self.recent(recent), direction: direction)
    }

    init(recent: Reading?) {
        self.init(before: nil, after: Self.recent(recent), direction: nil)
    }

    init(_ comparison: SessionComparison<some SessionMeasure>) {
        self.init(comparison, direction: comparison.direction)
    }

    init(_ comparison: SessionComparison<SessionEndTime>) {
        self.init(comparison, direction: nil)
    }

    private init(_ comparison: SessionComparison<some SessionFigure>, direction: Direction?) {
        let session = comparison.session
        let before = Value(
            title: String(localized: .fieldBeforeTitle),
            reading: comparison.baseline?.reading,
            footnote: String(localized: .fieldBeforeSubtitle(days: History.recentDays))
        )
        let after = Value(
            title: String(localized: .placeholder),
            reading: comparison.current.reading,
            footnote: session.startDate.formatted(session.localCalendar(from: .current).formatStyle(date: .abbreviated))
        )

        self.init(before: before, after: after, direction: direction)
    }

    private init(before: Value?, after: Value, direction: Direction?) {
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
            footnote: String(localized: .fieldRecentSubtitle(days: History.recentDays))
        )
    }
}

#Preview {
    let comparison = SessionComparison<SessionDuration>(Samples.sessions.first!, among: Samples.sessions)

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
