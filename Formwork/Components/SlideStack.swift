//
//  SlideStack.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

enum SlideDirection {
    case forward
    case backward

    var insertionEdge: Edge {
        self == .forward ? .trailing : .leading
    }

    var removalEdge: Edge {
        self == .forward ? .leading : .trailing
    }
}

struct SlideStack<Key: Hashable, Content: View>: View {
    private let key: Key?
    private let direction: SlideDirection
    private let animation: Animation
    private let fade: CGFloat
    private let onForward: (() -> Void)?
    private let onBackward: (() -> Void)?
    private let content: (Key) -> Content

    @State private var displayed: Key?
    @State private var page: Int = 0

    init(
        key: Key?,
        direction: SlideDirection,
        animation: Animation = .snappy,
        fade: CGFloat = 0,
        onForward: (() -> Void)? = nil,
        onBackward: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Key) -> Content
    ) {
        self.key = key
        self.direction = direction
        self.animation = animation
        self.fade = fade
        self.onForward = onForward
        self.onBackward = onBackward
        self.content = content
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: 16)
            .onEnded { value in
                guard
                    abs(value.translation.width) > abs(value.translation.height),
                    abs(value.translation.width) > 32
                else {
                    return
                }

                if value.translation.width < 0 {
                    onForward?()
                } else {
                    onBackward?()
                }
            }
    }

    var body: some View {
        ZStack {
            if let displayed {
                content(displayed)
                    .frame(maxWidth: .infinity)
                    .id(page)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: direction.insertionEdge),
                            removal: .move(edge: direction.removalEdge)
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .mask {
            HStack(spacing: 0) {
                LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                    .frame(width: fade)

                Rectangle()

                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: fade)
            }
            .padding(.vertical, -32)
        }
        .contentShape(.rect)
        .simultaneousGesture(swipe, including: onForward == nil && onBackward == nil ? .none : .all)
        .task {
            displayed = key
        }
        .onChange(of: key) { _, newValue in
            guard displayed != newValue else {
                return
            }

            withAnimation(animation) {
                displayed = newValue
                page += direction == .forward ? 1 : -1
            }
        }
    }
}
