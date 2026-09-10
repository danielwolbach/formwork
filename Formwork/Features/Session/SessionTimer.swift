//
//  SessionTimer.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

struct SessionTimer: View {
    let session: Session

    var body: some View {
        VStack(spacing: 2) {
            Text(session.workout?.title ?? String(localized: .unknown))
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)

            HStack {
                Text(verbatim: session.progressText)
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Divider()
                    .frame(height: 12)

                elapsed
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var elapsed: some View {
        if let ended = session.ended {
            Text(Duration.seconds(ended.timeIntervalSince(session.started)), format: .time(pattern: .hourMinuteSecond))
        } else {
            Text(session.started, style: .timer)
        }
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SessionTimer(session: Samples.session)
                }
            }
    }
    .sampleData()
}
