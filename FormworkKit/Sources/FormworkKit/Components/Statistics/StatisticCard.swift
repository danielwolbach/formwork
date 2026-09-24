//
//  StatisticCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import SwiftUI

/// A statistic of a history as a card that opens its sheet when tapped. Which days it looks at, whether it shows
/// a trend, how many tiles it takes and what its sheet shows are decided here, so every screen shows a statistic
/// the same way.
public struct StatisticCard: View {
    public enum Kind {
        case lastCompleted
        case weekStreak
        case weeklySessions
        case typicalDuration
        case typicalStartTime
        case completionRate
        case completions
        case favoriteWorkout
        case favoriteExercise
        case mostSkippedExercise
        case personalBest
        case activeDays
        case categories
        case progression
    }

    private let kind: Kind

    private let history: History

    public init(_ kind: Kind, of history: History) {
        self.kind = kind
        self.history = history
    }

    public var body: some View {
        card
            .modifier(DetailPresenter { sheet })
            .tileSpan(rows: span.rows, columns: span.columns)
    }

    /// Each reads right without saying which days it covers: rates and habits over the recent days, with a trend
    /// where they compare; counts, records and dates over all time; charts over whole weeks, about as many as a
    /// trend compares.
    @ViewBuilder
    private var card: some View {
        switch kind {
        case .lastCompleted: ValueCard(LastCompleted(history.allTime))
        case .weekStreak: ValueCard(WeekStreak(history.allTime))
        case .weeklySessions: ValueCard(Trend(WeeklySessions.self, of: history))
        case .typicalDuration: ValueCard(Trend(TypicalDuration.self, of: history))
        case .typicalStartTime: ValueCard(TypicalStartTime(history.recent))
        case .completionRate: ValueCard(Trend(CompletionRate.self, of: history))
        case .completions: ValueCard(Completions(history.allTime))
        case .favoriteWorkout: ValueCard(FavoriteWorkout(history.recent))
        case .favoriteExercise: ValueCard(FavoriteExercise(history.recent))
        case .mostSkippedExercise: ValueCard(MostSkippedExercise(history.recent))
        case .personalBest: ValueCard(PersonalBest(history.allTime))
        case .activeDays: ActiveDaysCard(ActiveDays(history.weeks(Self.chartWeeks)))
        case .categories: CategoriesCard(Categories(history.recent))
        case .progression: ProgressionCard(Progression(history.weeks(Self.chartWeeks)))
        }
    }

    @ViewBuilder
    private var sheet: some View {
        switch kind {
        case .lastCompleted: LastCompletedSheet(history: history)
        case .weekStreak: StreakSheet(history: history)
        case .weeklySessions: MetricSheet<WeeklySessions>(history: history)
        case .typicalDuration: MetricSheet<TypicalDuration>(history: history)
        case .typicalStartTime: ValuesSheet<TypicalStartTime>(history: history)
        case .completionRate: MetricSheet<CompletionRate>(history: history)
        case .completions: MetricSheet<Completions>(history: history)
        case .favoriteWorkout: ValuesSheet<FavoriteWorkout>(history: history)
        case .favoriteExercise: ValuesSheet<FavoriteExercise>(history: history)
        case .mostSkippedExercise: ValuesSheet<MostSkippedExercise>(history: history)
        case .personalBest: MetricSheet<PersonalBest>(history: history)
        case .activeDays: ActiveDaysSheet(history: history)
        case .categories: CategoriesSheet(history: history)
        case .progression: ProgressionSheet(history: history)
        }
    }

    private var span: (rows: Int, columns: Int) {
        switch kind {
        case .activeDays, .progression: (2, 2)
        case .categories: (1, 2)
        default: (1, 1)
        }
    }
}

extension StatisticCard {
    /// How many weeks a chart card shows: the recent days and the ones before, which a trend compares.
    private static var chartWeeks: Int {
        (History.recentDays + History.baselineDays) / 7
    }
}

/// Makes the card tappable and owns how the sheet is presented, so the sheet itself stays free of it. The sheet
/// is only built once it opens.
private struct DetailPresenter<Sheet: View>: ViewModifier {
    @ViewBuilder
    let sheet: () -> Sheet

    @State
    private var isPresented = false

    func body(content: Content) -> some View {
        Button {
            isPresented = true
        } label: {
            content
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented) {
            // No toolbar: the sheet is swiped away, which leaves its room to the content.
            ScrollView {
                // Only vertical: each part pads itself, so section headings sit inset like on every screen.
                sheet()
                    .padding(.vertical)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

private struct StatisticCardPreview: View {
    let workout: Workout

    let exercise: Exercise

    var body: some View {
        let history = History(.workout(workout))
        let exerciseHistory = History(.exercise(exercise))

        // Tap a card: each sheet shows what its statistic supports.
        TileGrid {
            StatisticCard(.typicalDuration, of: history)

            StatisticCard(.weekStreak, of: history)

            StatisticCard(.activeDays, of: history)

            StatisticCard(.categories, of: history)

            StatisticCard(.personalBest, of: exerciseHistory)

            StatisticCard(.completionRate, of: exerciseHistory)

            StatisticCard(.progression, of: exerciseHistory)
        }
    }
}

#Preview {
    ScrollView {
        StatisticCardPreview(workout: Samples.workouts[0], exercise: Samples.exercises[1])
            .padding()
    }
    .sampleData()
}
