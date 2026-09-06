//
//  FormworkWidgetsLiveActivity.swift
//  FormworkWidgets
//
//  Created by Daniel Wolbach on 06.09.26.
//

import ActivityKit
import AppIntents
import FormworkKit
import SwiftUI
import WidgetKit

struct SessionActivity: Widget {
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
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(context.state.pictogram.color)
            } compactTrailing: {
                remaining(for: context)
            } minimal: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(context.state.pictogram.color)
            }
            .widgetURL(DeepLink.session)
        }
    }
    
    private func pictogram(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        PictogramView(
            pictogram: context.state.pictogram,
            size: 40,
            badge: context.state.status
        )
    }

    private func description(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        VStack(alignment: .leading) {
            Text(context.state.title)
                .lineLimit(1)
                .font(.headline)
            
            Text(context.state.subtitle)
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func progress(for context: ActivityViewContext<SessionActivityAttributes>) -> some View {
        HStack {
            Text(context.attributes.started, style: .timer)
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
            Button(intent: SessionBackwardIntent()) {
                controlLabel("chevron.left")
            }
            .tint(.gray)
            .buttonBorderShape(.circle)
            .disabled(!context.state.canMoveBackward)
            
            if context.state.isPending {
                Button(intent: SessionCompleteIntent()) {
                    controlLabel("checkmark")
                }
                .tint(.green)
                .buttonBorderShape(.circle)
            } else {
                Button(intent: SessionUndoIntent()) {
                    controlLabel("arrow.uturn.backward")
                }
                .tint(.gray)
                .buttonBorderShape(.circle)
            }
            
            Button(intent: SessionForwardIntent()) {
                controlLabel("chevron.right")
            }
            .tint(.gray)
            .buttonBorderShape(.circle)
            .disabled(!context.state.canMoveForward)
        }
    }
    
    private func controlLabel(_ systemImage: String) -> some View {
        Image(systemName: systemImage)
            .frame(width: 20, height: 20)
    }
}

private extension SessionActivityAttributes {
    static var preview: Self {
        .init(workout: "Full Body", started: .now.addingTimeInterval(-1245))
    }
}

private extension SessionActivityAttributes.ContentState {
    static var preview: Self {
        .init(
            title: "Barbell Squat",
            subtitle: "3 × 8",
            pictogram: Pictogram(icon: "dumbbell", tint: .indigo),
            status: nil,
            resolved: 2,
            total: 5,
            isPending: true,
            isComplete: false,
            canMoveForward: true,
            canMoveBackward: true
        )
    }
    
    static var completed: Self {
        var state = Self.preview
        state.status = Pictogram(icon: "checkmark.circle.fill", tint: .green)
        state.isPending = false
        state.resolved = 3
        return state
    }
    
    static var atStart: Self {
        var state = Self.preview
        state.canMoveBackward = false
        state.resolved = 0
        return state
    }
    
    static var atEnd: Self {
        var state = Self.preview
        state.canMoveForward = false
        state.resolved = 4
        return state
    }
    
    static var finished: Self {
        var state = Self.preview
        state.subtitle = "Session complete"
        state.status = Pictogram(icon: "checkmark.circle.fill", tint: .green)
        state.isPending = false
        state.isComplete = true
        state.canMoveForward = false
        state.resolved = 5
        return state
    }
}

#Preview("Lock Screen", as: .content, using: SessionActivityAttributes.preview) {
    SessionActivity()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
    SessionActivityAttributes.ContentState.completed
    SessionActivityAttributes.ContentState.atStart
    SessionActivityAttributes.ContentState.atEnd
    SessionActivityAttributes.ContentState.finished
}

#Preview("Island Expanded", as: .dynamicIsland(.expanded), using: SessionActivityAttributes.preview) {
    SessionActivity()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
    SessionActivityAttributes.ContentState.completed
    SessionActivityAttributes.ContentState.atStart
    SessionActivityAttributes.ContentState.atEnd
    SessionActivityAttributes.ContentState.finished
}

#Preview("Island Compact", as: .dynamicIsland(.compact), using: SessionActivityAttributes.preview) {
    SessionActivity()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
    SessionActivityAttributes.ContentState.completed
    SessionActivityAttributes.ContentState.atEnd
}

#Preview("Island Minimal", as: .dynamicIsland(.minimal), using: SessionActivityAttributes.preview) {
    SessionActivity()
} contentStates: {
    SessionActivityAttributes.ContentState.preview
    SessionActivityAttributes.ContentState.completed
}
