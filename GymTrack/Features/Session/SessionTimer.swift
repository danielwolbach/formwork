//
//  SessionTimer.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct SessionTimer: View {
    @Bindable var session: Session

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { _ in
            let now = Date.now
            let elapsed = Duration.seconds(now.timeIntervalSince(session.started))

            HStack(spacing: 16) {
                timingItem(icon: "timer") {
                    Text(elapsed.formatted(.time(pattern: .hourMinute(padHourToLength: 1, roundSeconds: .down))))
                }

                if let estimatedRemainingDuration = session.estimatedRemainingDuration {
                    timingItem(icon: "flag.checkered") {
                        Text(estimatedFinishText(for: estimatedRemainingDuration, from: now))
                    }
                }
            }
        }
    }

    private func estimatedFinishText(for duration: Duration, from date: Date) -> String {
        let components = duration.components
        let timeInterval = Double(components.seconds) + Double(components.attoseconds) / 1e18
        let estimatedFinish = date.addingTimeInterval(timeInterval)
        let nextMinute = Calendar.autoupdatingCurrent.nextDate(
            after: estimatedFinish,
            matching: DateComponents(second: 0),
            matchingPolicy: .nextTime
        ) ?? estimatedFinish

        return nextMinute.formatted(date: .omitted, time: .shortened)
    }

    private func timingItem(
        icon: String,
        @ViewBuilder value: () -> some View
    ) -> some View {
        HStack {
            Image(systemName: icon)
            value()
        }
        .foregroundStyle(.secondary)
        .font(.caption.monospacedDigit().weight(.semibold))
    }
}

#Preview {
    SessionTimer(session: Session.samples[0])
}
