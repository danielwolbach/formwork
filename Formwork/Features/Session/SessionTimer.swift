//
//  SessionTimer.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

/// Elapsed time and progress of a session, sized for the toolbar.
struct SessionTimer: View {
    let session: Session
    
    var body: some View {
        VStack {
            Text(verbatim: "\(session.history.count) / \(session.entries.count)")
                .font(.caption)
                .fontWeight(.semibold)
                .monospacedDigit()
    
            HStack {
                HStack(spacing: 2) {
                    Image(systemName: "timer")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    
                    elapsed
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
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
