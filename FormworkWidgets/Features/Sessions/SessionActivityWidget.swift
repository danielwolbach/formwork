//
//  SessionActivityWidget.swift
//  FormworkWidgets
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit
import FormworkKit
import FormworkUI
import SwiftUI
import WidgetKit

struct SessionActivityWidget: Widget {
    private struct Content: View {
        let context: ActivityViewContext<SessionActivityAttributes>

        @Environment(\.activityFamily)
        private var family: ActivityFamily

        var body: some View {
            VStack {
                HStack {
                    if family != .small {
                        pictogram(for: context)
                    }

                    Spacer()

                    progress(for: context)
                }

                HStack {
                    description(for: context)

                    Spacer()

                    if family != .small {
                        controls(for: context)
                    }
                }
            }
            .padding()
        }
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityAttributes.self) { context in
            Content(context: context)
                .widgetURL(DeepLink.session)
                .activityBackgroundTint(context.state.workout.color.mix(with: .black, by: 0.5).opacity(0.9))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Self.pictogram(for: context)
                        .padding(.leading)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Self.progress(for: context)
                        .padding(.trailing)
                        .frame(height: 40)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Self.description(for: context)

                        Spacer()

                        Self.controls(for: context)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Image(systemName: context.state.workout.image)
                    .foregroundStyle(context.state.workout.color)
            } compactTrailing: {
                Self.remaining(for: context)
            } minimal: {
                Image(systemName: context.state.workout.image)
                    .foregroundStyle(context.state.workout.color)
            }
            .widgetURL(DeepLink.session)
        }
        .supplementalActivityFamilies([.small])
    }

    private static func pictogram(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        PictogramView(context.state.pictogram, badge: context.state.status)
            .frame(width: 40)
    }

    private static func description(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        VStack(alignment: .leading) {
            Text(context.state.title)
                .lineLimit(1)
                .font(.headline)

            TargetSubtitle(target: context.state.target)
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private static func progress(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
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

    private static func remaining(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
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

    private static func controls(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        HStack {
            Button(.backward, intent: SessionBackwardIntent())
                .tint(.gray)
                .buttonBorderShape(.circle)
                .opacity(context.state.canMoveBackward ? 1 : 0.5)
                .accessibilityHidden(!context.state.canMoveBackward)

            primaryAction(for: context)

            Button(.forward, intent: SessionForwardIntent())
                .tint(.gray)
                .buttonBorderShape(.circle)
                .opacity(context.state.canMoveForward ? 1 : 0.5)
                .accessibilityHidden(!context.state.canMoveForward)
        }
        .labelStyle(.fixedIconOnly)
    }

    @ViewBuilder
    private static func primaryAction(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        if context.state.resolved == context.state.total {
            Link(destination: DeepLink.session) {
                Label(.finishSession)
            }
            .fontWeight(.bold)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
        } else if context.state.status == nil {
            Button(.complete, intent: SessionCompleteIntent())
                .tint(.green)
                .buttonBorderShape(.circle)
        } else {
            Button(.undo, intent: SessionUndoIntent())
                .tint(.gray)
                .buttonBorderShape(.circle)
        }
    }
}

private struct TargetSubtitle: View {
    let target: ExerciseTarget

    @AppStorage(StorageKeys.weightSystem, store: AppGroup.defaults)
    private var weightSystem: Units.System = .current

    @AppStorage(StorageKeys.distanceSystem, store: AppGroup.defaults)
    private var distanceSystem: Units.System = .current

    var body: some View {
        Text(target.formatted(.exerciseTarget(units: Units(weight: weightSystem, distance: distanceSystem))))
    }
}

extension SessionActivityAttributes.ContentState {
    fileprivate static var preview: Self {
        .init(
            title: "Barbell Squat",
            target: .weight(kilograms: 80, reps: 8, sets: 3),
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
