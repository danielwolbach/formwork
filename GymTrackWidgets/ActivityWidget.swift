//
//  ActivityWidget.swift
//  GymTrackWidgets
//
//  Created by Daniel Wolbach on 07.08.26.
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct ActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityAttributes.self) { context in
            VStack {
                HStack {
                    icon(for: context)
                    Spacer()
                    remaining(for: context)
                }

                HStack {
                    description(for: context)
                    Spacer()
                    controls(for: context)
                }
            }
            .padding()
            .widgetURL(URL(string: "gymtrack://session"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    icon(for: context)
                        .padding(.leading)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    remaining(for: context)
                        .padding(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        description(for: context)
                        Spacer()
                        controls(for: context)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                icon(for: context)
            } compactTrailing: {
                remaining(for: context)
            } minimal: {
                icon(for: context)
            }
            .widgetURL(URL(string: "gymtrack://session"))
        }
    }

    private func description(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(context.state.exerciseName)
                    .lineLimit(1)
                    .font(.headline)

                Group {
                    if context.state.entryStatus == .done {
                        Image(systemName: "checkmark")
                            .tint(.green)
                    } else if context.state.entryStatus == .skipped {
                        Image(systemName: "arrow.turn.up.right")
                            .tint(.orange)
                    }
                }
                .font(.caption)
            }

            Text(context.state.subtitle)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
    }

    private func controls(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        HStack {
            if context.state.entryStatus == .pending {
                Button(intent: SessionCompleteActivityIntent(sessionID: context.attributes.sessionID.uuidString)) {
                    Image(systemName: "checkmark")
                }
                .tint(.green)
                .buttonBorderShape(.circle)
            } else {
                Button(intent: SessionUndoActivityIntent(sessionID: context.attributes.sessionID.uuidString)) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .tint(.gray)
                .buttonBorderShape(.circle)
            }

            Button(intent: SessionAdvanceActivityIntent(sessionID: context.attributes.sessionID.uuidString)) {
                Image(systemName: "forward.fill")
            }
            .tint(.gray)
            .buttonBorderShape(.circle)
        }
        .controlSize(.large)
    }

    private func icon(for _: ActivityViewContext<SessionActivityAttributes>) -> some View {
        Image(systemName: "figure.strengthtraining.traditional")
    }

    private func remaining(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text("\(context.state.completedCount)")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("/\(context.state.totalCount)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
        }
    }
}

private extension SessionActivityAttributes {
    static var preview: Self {
        .init(
            sessionID: UUID(),
            workoutName: "Full Body",
            started: .now.addingTimeInterval(-1245)
        )
    }
}

private extension SessionActivityAttributes.ContentState {
    static var preview: Self {
        .init(
            exerciseName: "Barbell Squat",
            subtitle: "3 × 8",
            completedCount: 2,
            totalCount: 5,
            entryStatus: .pending
        )
    }
}

#Preview("Session", as: .content, using: SessionActivityAttributes.preview) {
    ActivityWidget()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
}
