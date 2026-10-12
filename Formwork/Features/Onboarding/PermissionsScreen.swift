//
//  PermissionsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 12.10.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct PermissionsScreen: View {
    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @AppStorage(StorageKeys.onboardingPending)
    private var onboardingPending: Bool = true

    @State
    private var page: Page = .reminders

    @State
    private var prompted: Set<Page> = []

    var body: some View {
        OnboardingPager(selection: $page) { page in
            switch page {
            case .reminders: RemindersPreview()
            case .health: HealthPreview()
            }
        } controls: {
            Group {
                if prompted.contains(page) {
                    Button(.continue) {
                        advance()
                    }
                    .buttonStyle(.glassProminent)
                } else {
                    HStack(spacing: .groups) {
                        Button(.skip) {
                            advance()
                        }
                        .buttonStyle(.glass)

                        Button(.allow) {
                            allow()
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
            .transition(.blurReplace)
            .animation(.snappy, value: prompted.contains(page))
            .fontWeight(.semibold)
            .labelStyle(.fixedTitleAndIcon)
            .controlSize(.large)
        }
    }

    private func advance(completion: @escaping () -> Void = {}) {
        guard let next = page.next else {
            finish()
            return
        }

        withAnimation(.snappy, { page = next }, completion: completion)
    }

    private func allow() {
        let current = page

        Task {
            switch current {
            case .reminders: await Reminders.requestAuthorization()
            case .health: try? await Health.connect()
            }

            // Only once the page has turned, or the buttons switch to Continue on the way out.
            advance {
                prompted.insert(current)
            }
        }
    }

    private func finish() {
        onboardingPending = false
        dismiss()
    }
}

private enum Page: @MainActor OnboardingPage {
    case reminders, health

    var tint: Pictogram.Tint {
        switch self {
        case .reminders: .yellow
        case .health: .red
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .reminders: .permissionsRemindersTitle
        case .health: .permissionsHealthTitle
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .reminders: .permissionsRemindersMessage
        case .health: .permissionsHealthMessage
        }
    }
}

private struct RemindersPreview: View {
    private let reminders = StarterCatalog.Samples.reminders()

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(reminders.enumerated()), id: \.offset) { position, reminder in
                let depth = CGFloat(position)

                NotificationBanner(reminder: reminder)
                    .scaleEffect(1 - depth * 0.05, anchor: .top)
                    .opacity(1 - depth * 0.3)
            }
        }
        .background {
            Image(systemName: "bell")
                .font(.system(size: 160))
                .foregroundStyle(Page.reminders.tint.color.quaternary)
                .rotationEffect(.degrees(-12))
        }
    }
}

private struct NotificationBanner: View {
    let reminder: Reminder

    var body: some View {
        HStack(spacing: 12) {
            Image(.imageAppIcon)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(.rect(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(reminder.title)
                        .fontWeight(.semibold)

                    Spacer(minLength: 0)

                    Text(reminder.date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(reminder.message)
            }
            .font(.subheadline)
            .lineLimit(1)
        }
        .padding(14)
        .glassEffect(in: .rect(cornerRadius: 24, style: .continuous))
    }
}

private struct HealthPreview: View {
    @Environment(\.units)
    private var units: Units

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                PictogramView(Exercise.Kind.weight.pictogram)
                    .frame(width: 72, height: 72)

                arrow("arrow.left.arrow.right")

                PictogramView(Pictogram(image: "heart.fill", tint: Page.health.tint))
                    .frame(width: 120, height: 120)

                arrow("arrow.left.arrow.right")

                PictogramView(.bodyWeight)
                    .frame(width: 72, height: 72)
            }

            TileGrid {
                ReadingCard(Statistic.bodyWeight, reading: StarterCatalog.Samples.bodyWeight(in: units))
                ReadingCard(Statistic.bodyFat, reading: StarterCatalog.Samples.bodyFat)
            }
            .padding(.horizontal, 32)
        }
    }

    private func arrow(_ image: String) -> some View {
        Image(systemName: image)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.tertiary)
    }
}

#Preview {
    PermissionsScreen()
}
