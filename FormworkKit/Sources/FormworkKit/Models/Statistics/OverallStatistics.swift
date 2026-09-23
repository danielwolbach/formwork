//
//  OverallStatistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

import Foundation

public struct OverallStatistics {
    /// Consecutive weeks with at least one finished session as seen on the last day of the interval, or now
    /// while it's ongoing. The week containing that day doesn't break the streak until it's over.
    public let weekStreak: Metric<Int>

    /// The longest run of consecutive weeks with at least one finished session up to the end of the interval,
    /// or up to now while it's ongoing. For May, it's the best streak as seen on May 31.
    public let longestWeekStreak: Metric<Int>

    /// When the most recent session within the interval ended.
    public let lastSession: Metric<Date>

    /// The average number of finished sessions per week within the interval, counted from the first session
    /// ever if it's later, up to the last day of the interval, or now while it's ongoing. Covers at least a week.
    public let sessionsPerWeek: Metric<Double>

    /// How many sessions were finished within the interval.
    public let completions: Metric<Int>

    /// The workout finished most often within the interval, the most recently done one of them if several
    /// are level.
    public let favoriteWorkout: Metric<Workout>

    /// The median duration of a finished session within the interval.
    public let typicalDuration: Metric<Duration>

    /// The wall-clock time a session within the interval was typically started at, as hour and minute: the
    /// recorded start time closest to all the others on the clock.
    public let typicalStartTime: Metric<DateComponents>

    /// The days trained within the interval, week by week.
    public let activity: Heatmap

    /// What was trained within the interval, by the exercises actually completed.
    public let categories: Distribution<ExerciseCategory>

    init(sessions: [Session], interval: DateInterval = .allTime, now: Date = .now, calendar: Calendar = .current) {
        let context = StatisticsContext(sessions: sessions, interval: interval, calendar: calendar)
        let last = context.lastSession

        self.weekStreak = .weekStreak(context.currentWeekStreak(at: now))
        self.longestWeekStreak = .longestWeekStreak(context.longestWeekStreak(at: now))
        self.sessionsPerWeek = .sessionsPerWeek(context.sessionsPerWeek(at: now))
        self.lastSession = .lastCompleted(last?.ended, in: last, calendar: calendar)
        let workouts = context.sessions
            .reduce(into: [Workout: (count: Int, latest: Date)]()) { tally, session in
                guard let workout = session.workout else {
                    return
                }
                let current = tally[workout] ?? (0, .distantPast)
                tally[workout] = (current.count + 1, max(current.latest, session.ended ?? .distantPast))
            }

        self.completions = .completions(context.sessions.count)
        self.favoriteWorkout = .favoriteWorkout(workouts.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key)
        self.typicalDuration = .typicalDuration(context.typicalDuration)
        self.typicalStartTime = .typicalStartTime(context.typicalStartTime, calendar: calendar)
        self.activity = context.heatmap(of: context.sessions, at: now)
        self.categories = .categories(context.sessions.flatMap(\.entries).filter(\.status.isCompleted).compactMap(\.exercise))
    }
}

extension [Session] {
    public func statistics(in interval: DateInterval = .allTime) -> OverallStatistics {
        OverallStatistics(sessions: self, interval: interval)
    }
}
