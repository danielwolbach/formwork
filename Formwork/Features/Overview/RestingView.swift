//
//  RestingView.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct RestingView: View {
    enum Kind {
        case finished
        case unscheduled
    }

    let kind: Kind

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: pictogram.icon)
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(pictogram.color)
                .frame(width: 96, height: 96)

            VStack(spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 24)
        .cardFill(tint: pictogram.color)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }

    private var pictogram: Pictogram {
        switch kind {
        case .finished: Pictogram(icon: "checkmark.seal.fill", tint: .green)
        case .unscheduled: Pictogram(icon: "moon.zzz.fill", tint: .indigo)
        }
    }

    private var title: LocalizedStringResource {
        switch kind {
        case .finished: .overviewRestingFinishedTitle
        case .unscheduled: .overviewRestingUnscheduledTitle
        }
    }

    private var message: LocalizedStringResource {
        switch kind {
        case .finished: .overviewRestingFinishedMessage
        case .unscheduled: .overviewRestingUnscheduledMessage
        }
    }
}

#Preview {
    VStack {
        RestingView(kind: .finished)
        RestingView(kind: .unscheduled)
    }
    .padding()
}
