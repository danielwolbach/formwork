//
//  SessionEntryPager.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//  DISCLAIMER: This file was written using generative AI.
//

import FormworkKit
import SwiftUI
import UIKit

/// Moves through a session's entries and decides which way the pager slides.
///
/// Pages are placed by a running index instead of their position in `Session.orderedEntries`, so moving forward
/// always shifts the pages to the left, no matter where the new entry sits in that order.
@Observable
final class SessionNavigator {
    let session: Session

    fileprivate private(set) var index: Int = 0

    /// The direction of the last navigation: 1 for forward, -1 for backward.
    fileprivate private(set) var direction: Int = 1

    init(session: Session) {
        self.session = session
    }

    func forward() {
        navigate(by: 1) { session.moveToNext() }
    }

    func backward() {
        navigate(by: -1) { session.moveToPrevious() }
    }

    func complete() {
        navigate(by: 1) { session.completeAndAdvance() }
    }

    func skip() {
        navigate(by: 1) { session.skipAndAdvance() }
    }

    func undo() {
        withAnimation(.snappy) {
            session.undoStatusChange()
        }
    }

    private func navigate(by step: Int, _ change: () -> Void) {
        let previous = session.current?.identifier

        withAnimation(.snappy) {
            change()

            // Completing the last pending entry keeps it current, which must not slide.
            if session.current?.identifier != previous {
                index += step
                direction = step
            }
        }
    }
}

struct SessionEntryPager<Page: View>: View {
    let navigator: SessionNavigator

    @ViewBuilder let page: (SessionEntry) -> Page

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack {
                ForEach(slots) { slot in
                    let position = slot.key - navigator.index

                    page(slot.entry)
                        .frame(width: width, height: proxy.size.height)
                        .offset(x: CGFloat(position) * width + dragOffset)
                        .transition(transition(at: position, width: width))
                }
            }
            .frame(width: width, height: proxy.size.height)
            .contentShape(.rect)
            .gesture(PagingPanGesture(
                onChanged: { translation in dragChanged(translation) },
                onEnded: { predicted in dragEnded(predicted: predicted, width: width) }
            ))
        }
        .clipped()
    }

    /// Neighbors appear directly at their offscreen position, since sliding them in from even further out delays
    /// them when the user pages again quickly. Only a new current page, which replaces a different entry, slides in
    /// from the navigation direction. Pages that leave keep sliding outwards instead of vanishing mid-slide.
    private func transition(at position: Int, width: CGFloat) -> AnyTransition {
        let insertion: AnyTransition = position == 0 ? .offset(x: CGFloat(navigator.direction) * width) : .identity
        let removal: AnyTransition = position == 0 ? .identity : .offset(x: CGFloat(position.signum()) * width)

        return .asymmetric(insertion: insertion, removal: removal)
    }

    /// The current entry and two neighbors on each side. The outer neighbors keep pages that are still sliding out
    /// around when the user pages again quickly, so they are only removed once fully offscreen.
    private var slots: [Slot] {
        let session = navigator.session
        let ordered = session.orderedEntries

        guard let current = session.current, let center = ordered.firstIndex(where: { $0 === current }) else {
            return []
        }

        return (-2 ... 2).compactMap { offset in
            ordered.indices.contains(center + offset)
                ? Slot(key: navigator.index + offset, entry: ordered[center + offset])
                : nil
        }
    }

    private func dragChanged(_ translation: CGFloat) {
        let hasTarget = translation < 0 ? navigator.session.next != nil : navigator.session.previous != nil

        // Follow the finger 1-to-1, and resist when there is nothing to page to.
        dragOffset = hasTarget ? translation : translation / 3
    }

    private func dragEnded(predicted: CGFloat, width: CGFloat) {
        let session = navigator.session

        if predicted < -width / 2 {
            if session.next != nil {
                Haptics.impact(.soft)
                navigator.forward()
            } else {
                Haptics.impact(.rigid, intensity: 0.5)
            }
        } else if predicted > width / 2 {
            if session.previous != nil {
                Haptics.impact(.soft)
                navigator.backward()
            } else {
                Haptics.impact(.rigid, intensity: 0.5)
            }
        }

        withAnimation(.snappy) {
            dragOffset = 0
        }
    }
}

/// A horizontal pan that fails right away when a drag starts vertically, so the touch stays available to other
/// gestures such as swipe-to-dismiss. SwiftUI's `DragGesture` cannot decline a touch like this.
private struct PagingPanGesture: UIGestureRecognizerRepresentable {
    let onChanged: (CGFloat) -> Void

    /// Called with the predicted end translation, extrapolated from the release velocity.
    let onEnded: (CGFloat) -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context _: Context) {
        let translation = recognizer.translation(in: recognizer.view).x

        switch recognizer.state {
        case .changed:
            onChanged(translation)
        case .ended:
            // Same deceleration as a scroll view with the normal deceleration rate.
            let velocity = recognizer.velocity(in: recognizer.view).x
            onEnded(translation + velocity * 0.998 / (1 - 0.998) / 1000)
        case .cancelled, .failed:
            // Spring back without paging.
            onEnded(0)
        default:
            break
        }
    }

    func makeCoordinator(converter _: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
            guard let pan = recognizer as? UIPanGestureRecognizer else {
                return true
            }

            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y) * 1.5
        }
    }
}

/// A page position together with the entry it shows. When a position switches to a different entry, the page is
/// replaced instead of updated, so the new entry slides in rather than swapping its content mid-slide.
private struct Slot: Identifiable {
    let key: Int
    let entry: SessionEntry

    var id: String {
        "\(key):\(entry.identifier)"
    }
}
