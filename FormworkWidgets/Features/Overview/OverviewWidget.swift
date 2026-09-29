//
//  OverviewWidget.swift
//  FormworkWidgets
//
//  Created by Daniel Wolbach on 28.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI
import WidgetKit

struct OverviewWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKind.overview, provider: OverviewProvider()) { entry in
            OverviewWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [entry.tint, entry.tint.opacity(0.6)],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                }
        }
        .configurationDisplayName(.widgetOverviewTitle)
        .description(.widgetOverviewDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct OverviewWidgetView: View {
    private let entry: OverviewEntry

    @Environment(\.widgetFamily)
    private var family

    init(entry: OverviewEntry) {
        self.entry = entry
    }

    var body: some View {
        VStack(alignment: .leading) {
            Label {
                if isSmall {
                    Text(verbatim: entry.streak.formatted())
                } else {
                    Text(.widgetOverviewStreakTitle(count: entry.streak))
                }
            } icon: {
                Image(systemName: entry.isStreakFulfilled ? "flame.fill" : "flame")
            }
            .font(isSmall ? .headline : .title3)
            .fontWeight(.heavy)
            .foregroundStyle(.white.secondary)

            Spacer()

            VStack(alignment: .leading) {
                Text(.widgetOverviewTodayTitle)
                    .font(isSmall ? .headline : .title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(verbatim: entry.title)
                    .font(isSmall ? .title3 : .title)
                    .fontWeight(.heavy)
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            GeometryReader { geometry in
                let side = min(geometry.size.width, geometry.size.height)

                Image(systemName: entry.symbol)
                    .font(.system(size: side))
                    .foregroundStyle(.white.tertiary)
                    .offset(x: side * 0.1, y: -side * 0.1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .accessibilityHidden(true)
            }
        }
    }

    private var isSmall: Bool {
        family == .systemSmall
    }
}

struct OverviewEntry: TimelineEntry {
    let date: Date

    let streak: Int

    let isStreakFulfilled: Bool

    let title: String

    let symbol: String

    let tint: Color
}

extension OverviewEntry {
    static var sample: OverviewEntry {
        guard let workout = StarterCatalog.workouts.first else {
            preconditionFailure("The starter catalog has no workout.")
        }

        return OverviewEntry(
            date: .now,
            streak: 7,
            isStreakFulfilled: true,
            title: String(localized: workout.name),
            symbol: workout.pictogram.image,
            tint: workout.pictogram.color
        )
    }

    @MainActor
    static func current(at date: Date) -> OverviewEntry {
        let context = ModelContext(Storage.container)
        let sessions = (try? context.fetch(FetchDescriptor<Session>())) ?? []
        let workouts = (try? context.fetch(FetchDescriptor<Workout>())) ?? []
        let streak = WeekStreak(History(.all(sessions), at: date).allTime)
        let isScheduled = workouts.contains { $0.schedule.isScheduled(on: date) }
        let workout = workouts.pending(on: date).first

        return OverviewEntry(
            date: date,
            streak: streak.weeks,
            isStreakFulfilled: streak.isCurrentWeekFulfilled,
            title: workout?.title ?? String(localized: isScheduled ? .widgetOverviewAllDoneTitle : .widgetOverviewRestDayTitle),
            symbol: workout?.pictogram.image ?? (isScheduled ? "checkmark.seal.fill" : "moon.zzz.fill"),
            tint: workout?.pictogram.color ?? (isScheduled ? .green : .purple)
        )
    }
}

@MainActor
struct OverviewProvider: TimelineProvider {
    func placeholder(in _: Context) -> OverviewEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (OverviewEntry) -> Void) {
        completion(context.isPreview ? .sample : .current(at: .now))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<OverviewEntry>) -> Void) {
        let now = Date.now
        let midnight = Calendar.current.dateInterval(of: .day, for: now)?.end
        completion(Timeline(entries: [.current(at: now)], policy: midnight.map { .after($0) } ?? .atEnd))
    }
}

#Preview("Small", as: .systemSmall) {
    OverviewWidget()
} timeline: {
    OverviewEntry.sample
}

#Preview("Medium", as: .systemMedium) {
    OverviewWidget()
} timeline: {
    OverviewEntry.sample
}
