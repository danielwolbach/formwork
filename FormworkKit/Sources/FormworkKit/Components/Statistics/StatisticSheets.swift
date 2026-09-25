//
//  StatisticSheets.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import SwiftUI

// What a `StatisticCard` opens, worked out from the history once it does. Every metric gets the same sheet:
// whether it compares with the days before follows from its tolerance.

/// A metric's recent and all-time values, the days before next to the recent ones if it compares, then its year
/// by month.
struct MetricSheet<M: Metric>: View {
    let history: History

    var body: some View {
        let overall = M(history.allTime)

        StatisticSheet(overall, of: history) {
            ValuesCard(Trend(M.self, of: history), overall: overall.subtitle)
                .padding(.horizontal)

            YearSection(years: history.years, subtitle: String(localized: .statisticByMonthSubtitle)) { year in
                MonthlyChart(series: Series(M.self, of: history, year: year), label: overall.label(for:))
            }
        }
    }
}

/// The recent and all-time values of a statistic that isn't a number, so there's no trend or chart to it.
struct ValuesSheet<S: Statistic>: View {
    let history: History

    var body: some View {
        let overall = S(history.allTime)

        StatisticSheet(overall, of: history) {
            ValuesCard(pictogram: overall.pictogram, recent: S(history.recent).subtitle, overall: overall.subtitle)
                .padding(.horizontal)
        }
    }
}

/// The date on its own: there's nothing to compare it with.
struct LastCompletedSheet: View {
    let history: History

    var body: some View {
        let lastCompleted = LastCompleted(history.allTime)

        StatisticSheet(lastCompleted, of: history) {
            ChartCard {
                ValueRow(title: lastCompleted.title, value: lastCompleted.subtitle)
            }
            .padding(.horizontal)
        }
    }
}

/// The current streak and the longest.
struct StreakSheet: View {
    let history: History

    var body: some View {
        let current = WeekStreak(history.allTime)
        let longest = LongestWeekStreak(history.allTime)

        StatisticSheet(current, of: history) {
            ChartCard {
                VStack(spacing: 16) {
                    ValueRow(title: current.title, value: current.subtitle)

                    Divider()

                    ValueRow(title: longest.title, value: longest.subtitle)
                }
            }
            .padding(.horizontal)
        }
    }
}

/// Weekly active days as the values, then the year as a calendar.
struct ActiveDaysSheet: View {
    let history: History

    var body: some View {
        StatisticSheet(ActiveDays(history.recent), of: history) {
            ValuesCard(Trend(WeeklyActiveDays.self, of: history), overall: WeeklyActiveDays(history.allTime).subtitle)
                .padding(.horizontal)

            YearSection(years: history.years, subtitle: String(localized: .statisticByMonthSubtitle)) { year in
                ActiveDaysYear(activeDays: ActiveDays(history.year(year)))
            }
        }
    }
}

/// Recent and all-time shares, then month by month.
struct CategoriesSheet: View {
    let history: History

    var body: some View {
        let recent = Categories(history.recent)

        StatisticSheet(recent, of: history) {
            SectionView(.statisticRecentSubtitle(History.recentDays)) {
                ChartCard {
                    CategoriesBreakdown(categories: recent)
                }
                .padding(.horizontal)
            }

            SectionView(.statisticAllTimeTitle) {
                ChartCard {
                    CategoriesBreakdown(categories: Categories(history.allTime))
                }
                .padding(.horizontal)
            }

            YearSection(years: history.years, subtitle: String(localized: .statisticCategoriesByMonthSubtitle)) { year in
                CategoriesChart(series: Series(Categories.self, of: history, year: year))
            }
        }
    }
}

/// The typical best before and now and the personal best, then the year as a curve.
struct ProgressionSheet: View {
    let history: History

    var body: some View {
        let best = PersonalBest(history.allTime)

        StatisticSheet(Progression(history.recent), of: history) {
            ValuesCard(Trend(TypicalBest.self, of: history), overallTitle: best.title, overall: best.subtitle)
                .padding(.horizontal)

            YearSection(years: history.years, subtitle: String(localized: .statisticProgressionByDaySubtitle)) { year in
                ProgressionChart(progression: Progression(history.year(year)), isYear: true)
                    .frame(height: 180)
                    .padding(.top)
            }
        }
    }
}

/// The sheet's layout: what the statistic is and what it's about, its values and charts, and at the end what it
/// means.
private struct StatisticSheet<Content: View>: View {
    let pictogram: Pictogram

    let title: String

    let subject: String

    let explanation: String

    @ViewBuilder
    let content: Content

    var body: some View {
        VStack(spacing: 32) {
            PictogramRow(pictogram: pictogram, title: title, subtitle: subject)
                .padding(.horizontal)

            content

            SectionView(.statisticAboutTitle) {
                Text(explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    // Flush with the heading's text, which is nudged in to sit flush with the cards.
                    .padding(.horizontal, 2)
            }
        }
        .padding(.top)
    }
}

extension StatisticSheet {
    init<S: Statistic>(_ statistic: S, of history: History, @ViewBuilder content: () -> Content) {
        self.init(pictogram: statistic.pictogram, title: statistic.title, subject: history.subject.title, explanation: S.explanation, content: content)
    }
}

/// The values in one card. With a baseline, three equal columns read left to right as where the value went from
/// and to; the overall value follows below a divider.
private struct ValuesCard: View {
    let pictogram: Pictogram

    let recent: String?

    var baseline: String?

    var direction: Direction?

    var overallTitle = String(localized: .statisticAllTimeTitle)

    let overall: String?

    var body: some View {
        ChartCard {
            VStack(spacing: 16) {
                if let baseline, let direction {
                    HStack(spacing: 12) {
                        column(title: String(localized: .statisticBaselineTitle), value: baseline, footnote: String(localized: .statisticBaselineSubtitle(History.baselineDays)))

                        Image(systemName: direction.image)
                            .font(.title.weight(.semibold))
                            .foregroundStyle(pictogram.color)
                            .frame(maxWidth: .infinity)

                        column(title: String(localized: .statisticRecentTitle), value: recent, footnote: String(localized: .statisticRecentSubtitle(History.recentDays)))
                    }
                } else {
                    ValueRow(title: String(localized: .statisticRecentTitle), footnote: String(localized: .statisticRecentSubtitle(History.recentDays)), value: recent)
                }

                Divider()

                ValueRow(title: overallTitle, value: overall)
            }
        }
    }

    private func column(title: String, value: String?, footnote: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(verbatim: value ?? "—")
                .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.4)

            Text(footnote)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

extension ValuesCard {
    init(_ trend: Trend<some Metric>, overallTitle: String = String(localized: .statisticAllTimeTitle), overall: String?) {
        self.init(
            pictogram: trend.recent.pictogram,
            recent: trend.recent.subtitle,
            baseline: trend.baseline?.subtitle,
            direction: trend.direction,
            overallTitle: overallTitle,
            overall: overall
        )
    }
}

private struct ValueRow: View {
    let title: String

    var footnote: String?

    let value: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                if let footnote {
                    Text(footnote)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(verbatim: value ?? "—")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

/// A year's chart in a card, titled with the year and paged through `years`, starting with the latest.
private struct YearSection<Content: View>: View {
    let years: ClosedRange<Int>

    let subtitle: String

    @ViewBuilder
    let content: (Int) -> Content

    @State
    private var selection: Int?

    var body: some View {
        let year = selection ?? years.upperBound

        SectionView(String(year), subtitle: subtitle) {
            ChartCard {
                content(year)
            }
            .padding(.horizontal)
        } accessory: {
            HStack {
                Button(.backward) {
                    selection = year - 1
                }
                .disabled(year <= years.lowerBound)

                Button(.forward) {
                    selection = year + 1
                }
                .disabled(year >= years.upperBound)
            }
            .labelStyle(.fixedIconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
    }
}

extension History.Subject {
    fileprivate var title: String {
        switch self {
        case .all: String(localized: .statisticSubjectAllTitle)
        case let .workout(workout): workout.title
        case let .exercise(exercise): exercise.title
        case let .entry(slot): slot.title
        }
    }
}

private struct StatisticSheetsPreview: View {
    let workout: Workout

    var body: some View {
        ScrollView {
            MetricSheet<TypicalDuration>(history: History(.workout(workout)))
                .padding(.vertical)
        }
    }
}

#Preview {
    StatisticSheetsPreview(workout: Samples.workouts[0])
        .sampleData()
}
