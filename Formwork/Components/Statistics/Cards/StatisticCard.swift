//
//  StatisticCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import SwiftUI

struct StatisticCard: View {
    enum Kind {
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
        case totalVolume
        case oneRepMax
        case typicalInterval
    }

    private let kind: Kind

    private let history: History

    @State
    private var detailSheet: Bool = false

    init(_ kind: Kind, of history: History) {
        self.kind = kind
        self.history = history
    }

    var body: some View {
        Button {
            detailSheet = true
        } label: {
            card
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $detailSheet) {
            NavigationStack {
                sheet
            }
            .presentationDetents([.medium, .large])
        }
    }

    @ViewBuilder
    private var card: some View {
        switch kind {
        case .lastCompleted: MetricCard(LastCompleted(history.allTime))
        case .weekStreak: MetricCard(WeekStreak(history.allTime))
        case .weeklySessions: MetricCard(Trend<WeeklySessions>(history))
        case .typicalDuration: MetricCard(Trend<TypicalDuration>(history))
        case .typicalStartTime: MetricCard(TypicalStartTime(history.recent))
        case .completionRate: MetricCard(Trend<CompletionRate>(history))
        case .completions: MetricCard(Trend<Completions>(history))
        case .favoriteWorkout: MetricCard(FavoriteWorkout(history.recent))
        case .favoriteExercise: MetricCard(FavoriteExercise(history.recent))
        case .mostSkippedExercise: MetricCard(MostSkippedExercise(history.recent))
        case .personalBest: MetricCard(PersonalBest(history.allTime))
        case .activeDays: ActiveDaysCard(ActiveDays(history.weeks(Self.activeDaysWeeks)))
        case .categories: CategoriesCard(Categories(history.recent))
        case .progression: ProgressionCard(Progression(history.weeks(54)))
        case .totalVolume: MetricCard(Trend<TotalVolume>(history))
        case .oneRepMax: MetricCard(OneRepMax(history.allTime))
        case .typicalInterval: MetricCard(Trend<TypicalInterval>(history))
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
        case .totalVolume: MetricSheet<TotalVolume>(history: history)
        case .oneRepMax: MetricSheet<OneRepMax>(history: history)
        case .typicalInterval: MetricSheet<TypicalInterval>(history: history)
        }
    }
}

extension StatisticCard {
    private static var activeDaysWeeks: Int {
        (History.recentDays + History.baselineDays) / 7
    }
}
