//
//  SessionStatus.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionStatus: View {
    private let session: Session

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        VStack(spacing: 2) {
            if let workout = session.workout {
                Text(workout.title)
                    .lineLimit(1)
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            HStack {
                Text(verbatim: "\(session.resolvedCount) / \((session.entries ?? []).count)")
                    .contentTransition(.numericText(value: Double(session.resolvedCount)))

                Divider()
                    .frame(height: 12)

                elapsed
            }
            .font(.caption2)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var elapsed: some View {
        if let ended = session.endDate {
            Text(formatted(ended.timeIntervalSince(session.startDate)))
        } else {
            TimelineView(.periodic(from: session.startDate, by: 1)) { context in
                let text = formatted(context.date.timeIntervalSince(session.startDate))

                Text(text)
                    .contentTransition(.numericText(countsDown: false))
                    .animation(.default, value: text)
            }
        }
    }

    private func formatted(_ interval: TimeInterval) -> String {
        let duration = Duration.seconds(interval)

        return if duration < .seconds(3600) {
            duration.formatted(.time(pattern: .minuteSecond))
        } else {
            duration.formatted(.time(pattern: .hourMinute(padHourToLength: 1, roundSeconds: .down)))
        }
    }
}

#Preview {
    NavigationRoot {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SessionStatus(Samples.activeSession)
                }
            }
    }
    .sampleData()
}
