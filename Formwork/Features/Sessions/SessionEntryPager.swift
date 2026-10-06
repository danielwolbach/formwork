//
//  SessionEntryPager.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI
import UIKit

@Observable
final class SessionNavigator {
    let session: Session

    fileprivate private(set) var index: Int = 0

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

    func remove() {
        guard let entry = session.currentEntry else {
            return
        }

        // Without anything left to play, the player falls back to the last resolved entry, which sits before it.
        let step = session.pendingEntries.contains { $0 !== entry } ? 1 : -1
        navigate(by: step) { session.remove(entry) }
    }

    func undo() {
        withAnimation(.snappy) {
            session.undoCurrentStatus()
        }
    }

    private func navigate(by step: Int, _ change: () -> Void) {
        let previous = session.currentEntry?.identifier

        withAnimation(.snappy) {
            change()

            if session.currentEntry?.identifier != previous {
                index += step
                direction = step
            }
        }
    }
}

struct SessionEntryPager<Page: View>: View {
    let navigator: SessionNavigator

    @ViewBuilder
    let page: (SessionEntry) -> Page

    @State
    private var dragOffset: CGFloat = 0

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
        .sensoryFeedback(.impact(flexibility: .soft), trigger: navigator.index)
    }

    private var slots: [Slot] {
        let session = navigator.session

        // Observes the session on its own, so it can redraw after a replaced session was deleted and saved.
        guard !session.isDeleted, session.modelContext != nil else {
            return []
        }

        let ordered = session.orderedEntries

        guard let current = session.currentEntry, let center = ordered.firstIndex(where: { $0 === current }) else {
            return []
        }

        return (-2 ... 2).compactMap { offset in
            ordered.indices.contains(center + offset)
                ? Slot(key: navigator.index + offset, entry: ordered[center + offset])
                : nil
        }
    }

    private func transition(at position: Int, width: CGFloat) -> AnyTransition {
        let insertion: AnyTransition = position == 0 ? .offset(x: CGFloat(navigator.direction) * width) : .identity
        let removal: AnyTransition = position == 0 ? .identity : .offset(x: CGFloat(position.signum()) * width)

        return .asymmetric(insertion: insertion, removal: removal)
    }

    private func dragChanged(_ translation: CGFloat) {
        let hasTarget = translation < 0 ? navigator.session.nextEntry != nil : navigator.session.previousEntry != nil
        dragOffset = hasTarget ? translation : translation / 3
    }

    private func dragEnded(predicted: CGFloat, width: CGFloat) {
        let session = navigator.session

        if predicted < -width / 2 {
            if session.nextEntry != nil {
                navigator.forward()
            }
        } else if predicted > width / 2 {
            if session.previousEntry != nil {
                navigator.backward()
            }
        }

        withAnimation(.snappy) {
            dragOffset = 0
        }
    }
}

private struct PagingPanGesture: UIGestureRecognizerRepresentable {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
            guard let pan = recognizer as? UIPanGestureRecognizer else {
                return true
            }

            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y) * 1.5
        }
    }

    let onChanged: (CGFloat) -> Void

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
            let velocity = recognizer.velocity(in: recognizer.view).x
            onEnded(translation + velocity * 0.998 / (1 - 0.998) / 1000)
        case .cancelled, .failed:
            onEnded(0)
        default:
            break
        }
    }

    func makeCoordinator(converter _: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
}

private struct Slot {
    let key: Int

    let entry: SessionEntry
}

extension Slot: Identifiable {
    var id: String {
        "\(key):\(entry.identifier)"
    }
}
