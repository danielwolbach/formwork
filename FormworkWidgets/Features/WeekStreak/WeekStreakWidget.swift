//
//  WeekStreakWidget.swift
//  FormworkWidgets
//
//  Created by Daniel Wolbach on 28.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI
import WidgetKit

struct WeekStreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKind.weekStreak, provider: WeekStreakProvider()) { entry in
            WeekStreakWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [entry.tint, entry.tint.opacity(0.6)],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                }
        }
        .configurationDisplayName(.widgetWeekStreakTitle)
        .description(.widgetWeekStreakDescription)
        .supportedFamilies([.systemSmall])
    }
}

struct WeekStreakWidgetView: View {
    private let entry: WeekStreakEntry

    init(entry: WeekStreakEntry) {
        self.entry = entry
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(.widgetWeekStreakTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundStyle(.white.secondary)

                    Text(verbatim: entry.streak.formatted())
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .fontDesign(.rounded)
                }

                Spacer()
            }

            Spacer()

            WeekRow(entry.week, today: entry.date, tint: entry.tint)
        }
        .background {
            GeometryReader { geometry in
                let side = min(geometry.size.height, geometry.size.width)

                Image(systemName: entry.symbol)
                    .font(.system(size: side))
                    .foregroundStyle(entry.tint)
                    .offset(x: side * 0.25, y: -side * (1.0 / 3.0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .accessibilityHidden(true)
            }
        }
    }
}

private struct WeekRow: View {
    private let week: ActiveDays

    private let today: Date

    private let tint: Color

    init(_ week: ActiveDays, today: Date, tint: Color) {
        self.week = week
        self.today = today
        self.tint = tint
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(week.days) { day in
                let trained = day.sessionCount > 0
                let isToday = week.calendar.isDate(day.date, inSameDayAs: today)

                Circle()
                    .fill(.white.opacity(trained ? 1 : day.isAhead ? 0.1 : 0.25))
                    .overlay {
                        if trained {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(tint)
                        } else if isToday {
                            Circle()
                                .strokeBorder(.white, lineWidth: 1.5)
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct WeekStreakEntry: TimelineEntry {
    let date: Date

    let streak: Int

    let isStreakFulfilled: Bool

    let week: ActiveDays
}

extension WeekStreakEntry {
    static var sample: WeekStreakEntry {
        let week = StarterCatalog.Samples.activeWeek()
        let today = week.days.last { !$0.isAhead }?.date ?? .now

        return WeekStreakEntry(date: today, streak: 7, isStreakFulfilled: true, week: week)
    }

    var symbol: String {
        isStreakFulfilled ? "flame.fill" : "flame"
    }

    var tint: Color {
        isStreakFulfilled ? Pictogram.streak.color : .gray
    }

    @MainActor
    static func current(at date: Date) -> WeekStreakEntry {
        let context = ModelContext(Storage.container)
        let sessions = (try? context.fetch(FetchDescriptor<Session>())) ?? []
        let history = History(.all(sessions), at: date)
        let streak = WeekStreak(history.allTime)

        return WeekStreakEntry(date: date, streak: streak.weeks, isStreakFulfilled: streak.isCurrentWeekFulfilled, week: ActiveDays(history.weeks(1)))
    }
}

@MainActor
struct WeekStreakProvider: TimelineProvider {
    func placeholder(in _: Context) -> WeekStreakEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (WeekStreakEntry) -> Void) {
        completion(context.isPreview ? .sample : .current(at: .now))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<WeekStreakEntry>) -> Void) {
        let now = Date.now
        let midnight = Calendar.current.dateInterval(of: .day, for: now)?.end
        completion(Timeline(entries: [.current(at: now)], policy: midnight.map { .after($0) } ?? .atEnd))
    }
}

#Preview("Small", as: .systemSmall) {
    WeekStreakWidget()
} timeline: {
    WeekStreakEntry.sample
}
