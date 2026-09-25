//
//  SessionActivityWidget.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit
import FormworkKit
import SwiftUI
import WidgetKit

struct SessionActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityAttributes.self) { context in
            VStack {
                HStack {
                    pictogram(for: context)
                    Spacer()
                    progress(for: context)
                }

                HStack {
                    description(for: context)
                    Spacer()
                    controls(for: context)
                }
            }
            .padding()
            .widgetURL(DeepLink.session)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    pictogram(for: context)
                        .padding(.leading)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    progress(for: context)
                        .padding(.trailing)
                        .frame(height: 40)
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
                Image(systemName: context.state.workout.image)
                    .foregroundStyle(context.state.workout.color)
            } compactTrailing: {
                remaining(for: context)
            } minimal: {
                Image(systemName: context.state.workout.image)
                    .foregroundStyle(context.state.workout.color)
            }
            .widgetURL(DeepLink.session)
        }
    }

    private func pictogram(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        PictogramView(pictogram: context.state.pictogram, badge: context.state.status)
            .frame(width: 40)
    }

    private func description(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        VStack(alignment: .leading) {
            Text(context.state.title)
                .lineLimit(1)
                .font(.headline)

            if let subtitle = context.state.subtitle {
                Text(subtitle)
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func progress(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        HStack {
            Text(context.state.startDate, style: .timer)
                .monospacedDigit()
                .font(.footnote)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)

            Divider()
                .frame(height: 16)

            remaining(for: context)
        }
    }

    private func remaining(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text(verbatim: "\(context.state.resolved)")
                .font(.footnote)
                .fontWeight(.semibold)

            Text(verbatim: "/\(context.state.total)")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .monospacedDigit()
    }

    private func controls(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        HStack {
            Button(.backward, intent: SessionBackwardIntent())
                .tint(.gray)
                .buttonBorderShape(.circle)
                .opacity(context.state.canMoveBackward ? 1 : 0.5)
                .accessibilityHidden(!context.state.canMoveBackward)

            if context.state.status == nil {
                Button(.complete, intent: SessionCompleteIntent())
                    .tint(.green)
                    .buttonBorderShape(.circle)
            } else {
                Button(.undo, intent: SessionUndoIntent())
                    .tint(.gray)
                    .buttonBorderShape(.circle)
            }

            Button(.forward, intent: SessionForwardIntent())
                .tint(.gray)
                .buttonBorderShape(.circle)
                .opacity(context.state.canMoveForward ? 1 : 0.5)
                .accessibilityHidden(!context.state.canMoveForward)
        }
        .labelStyle(.fixedIconOnly)
    }
}

extension SessionActivityAttributes.ContentState {
    fileprivate static var preview: Self {
        .init(
            title: "Barbell Squat",
            subtitle: "3 × 8",
            pictogram: Pictogram(image: "dumbbell", tint: .indigo),
            workout: .workout,
            status: nil,
            startDate: .now.addingTimeInterval(-1245),
            resolved: 2,
            total: 5,
            canMoveForward: true,
            canMoveBackward: true
        )
    }

    fileprivate static var completed: Self {
        var state = Self.preview
        state.status = Pictogram(image: "checkmark.circle.fill", tint: .green)
        state.resolved = 3
        return state
    }

    fileprivate static var atStart: Self {
        var state = Self.preview
        state.canMoveBackward = false
        state.resolved = 0
        return state
    }

    fileprivate static var atEnd: Self {
        var state = Self.preview
        state.canMoveForward = false
        state.resolved = 4
        return state
    }

    fileprivate static var finished: Self {
        var state = Self.preview
        state.subtitle = "Session complete"
        state.status = Pictogram(image: "checkmark.circle.fill", tint: .green)
        state.canMoveForward = false
        state.resolved = 5
        return state
    }
}

#Preview("Lock Screen", as: .content, using: SessionActivityAttributes()) {
    SessionActivityWidget()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
    SessionActivityAttributes.ContentState.completed
    SessionActivityAttributes.ContentState.atStart
    SessionActivityAttributes.ContentState.atEnd
    SessionActivityAttributes.ContentState.finished
}

#Preview("Island Expanded", as: .dynamicIsland(.expanded), using: SessionActivityAttributes()) {
    SessionActivityWidget()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
    SessionActivityAttributes.ContentState.completed
    SessionActivityAttributes.ContentState.atStart
    SessionActivityAttributes.ContentState.atEnd
    SessionActivityAttributes.ContentState.finished
}

#Preview("Island Compact", as: .dynamicIsland(.compact), using: SessionActivityAttributes()) {
    SessionActivityWidget()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
    SessionActivityAttributes.ContentState.completed
    SessionActivityAttributes.ContentState.atEnd
}

#Preview("Island Minimal", as: .dynamicIsland(.minimal), using: SessionActivityAttributes()) {
    SessionActivityWidget()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
    SessionActivityAttributes.ContentState.completed
}
