//
//  SessionElapsedTime.swift
//  Formwork
//
//  Created by Daniel Wolbach on 12.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct SessionElapsedTime: View {
    private let session: Session

    init(_ session: Session) {
        self.session = session
    }

    var body: some View {
        if let endDate = session.endDate {
            let elapsed = endDate.timeIntervalSince(session.startDate)

            Text(formatted(elapsed))
                .accessibilityLabel(spoken(elapsed))
        } else {
            TimelineView(.periodic(from: session.startDate, by: 1)) { context in
                let elapsed = context.date.timeIntervalSince(session.startDate)
                let text = formatted(elapsed)

                Text(text)
                    .contentTransition(.numericText(countsDown: false))
                    .animation(.default, value: text)
                    // Read as a time of day otherwise.
                    .accessibilityLabel(spoken(elapsed))
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

    private func spoken(_ interval: TimeInterval) -> String {
        Duration.seconds(interval).formatted(.units(width: .wide))
    }
}

#Preview {
    SessionElapsedTime(Samples.activeSession)
        .monospacedDigit()
        .sampleData()
}
