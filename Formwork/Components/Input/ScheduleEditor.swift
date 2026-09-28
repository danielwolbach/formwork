//
//  ScheduleEditor.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

struct ScheduleEditor: View {
    private enum Rhythm: Hashable {
        case weekly, daily
    }

    private static let weekIntervals = 1 ... 4

    private static let dayIntervals = 1 ... 14

    private let saved: Schedule?

    private let calendar: Calendar

    @Binding
    private var schedule: Schedule

    init(_ schedule: Binding<Schedule>, saved: Schedule? = nil, calendar: Calendar = .current) {
        self._schedule = schedule
        self.saved = saved
        self.calendar = calendar
    }

    var body: some View {
        VStack(spacing: 24) {
            rhythmPicker

            Divider()

            switch schedule {
            case .weekly: weeklyScheduleEditor
            case .daily: dailyScheduleEditor
            }
        }
        .animation(.snappy, value: schedule)
    }

    private var rhythmPicker: some View {
        Picker(.fieldRhythmTitle, selection: rhythm) {
            Text(.fieldRhythmWeeklyTitle)
                .tag(Rhythm.weekly)

            Text(.fieldRhythmDailyTitle)
                .tag(Rhythm.daily)
        }
        .pickerStyle(.palette)
    }

    private var weeklyScheduleEditor: some View {
        VStack(spacing: 24) {
            WeekdayPicker(weekdays, calendar: calendar)

            // A weekly schedule without weekdays is inactive, so there's no rhythm to set yet.
            if !schedule.weekdays.isEmpty {
                intervalStepper(
                    Text(.fieldRhythmWeeklyItervalTitle(count: schedule.interval)),
                    range: Self.weekIntervals
                )

                anchorPicker
            }
        }
    }

    private var dailyScheduleEditor: some View {
        VStack(spacing: 24) {
            intervalStepper(
                Text(.fieldRhythmDailyIntervalTitle(count: schedule.interval)),
                range: Self.dayIntervals
            )

            anchorPicker
        }
    }

    private var anchorPicker: some View {
        HStack {
            Text(.fieldStartDateTitle)

            Spacer(minLength: 0)

            DateButton(date: $schedule.anchor)
        }
    }

    private var rhythm: Binding<Rhythm> {
        Binding(
            get: {
                Self.rhythm(of: schedule)
            },
            set: { newValue in
                if let saved, Self.rhythm(of: saved) == newValue {
                    schedule = saved
                    return
                }

                switch (schedule, newValue) {
                case let (.weekly(weekdays, interval, anchor), .daily):
                    schedule = .daily(interval: min(interval, Self.dayIntervals.upperBound), anchor: weekdays.isEmpty ? .now : anchor)
                case let (.daily(interval, anchor), .weekly):
                    schedule = .weekly(interval: min(interval, Self.weekIntervals.upperBound), anchor: anchor)
                default:
                    break
                }
            }
        )
    }

    private var weekdays: Binding<Schedule.Weekdays> {
        Binding(
            get: {
                schedule.weekdays
            },
            set: { newValue in
                // Picking the first weekday activates the schedule, so it starts now.
                if schedule.weekdays.isEmpty {
                    schedule.anchor = .now
                }

                schedule.weekdays = newValue
            }
        )
    }

    private static func rhythm(of schedule: Schedule) -> Rhythm {
        switch schedule {
        case .weekly: .weekly
        case .daily: .daily
        }
    }

    private func intervalStepper(_ title: Text, range: ClosedRange<Int>) -> some View {
        HStack {
            title

            Spacer(minLength: 0)

            Button(.decrease) {
                schedule.interval -= 1
            }
            .buttonStyle(.card())
            .labelStyle(.fixedIconOnly)
            .disabled(schedule.interval <= range.lowerBound)

            Button(.increase) {
                schedule.interval += 1
            }
            .buttonStyle(.card())
            .labelStyle(.fixedIconOnly)
            .disabled(schedule.interval >= range.upperBound)
        }
    }
}

private struct WeekdayPicker: View {
    private let calendar: Calendar

    @Binding
    private var weekdays: Schedule.Weekdays

    init(_ weekdays: Binding<Schedule.Weekdays>, calendar: Calendar) {
        self._weekdays = weekdays
        self.calendar = calendar
    }

    var body: some View {
        HStack {
            ForEach(Schedule.Weekday.ordered(in: calendar)) { weekday in
                Toggle(isOn: isSelected(Schedule.Weekdays([weekday]))) {
                    Text(weekday.symbol(in: calendar))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .toggleStyle(.card())
                .buttonBorderShape(.circle)
                .aspectRatio(1, contentMode: .fit)
                .accessibilityLabel(weekday.name(in: calendar))
            }
        }
        .sensoryFeedback(.selection, trigger: weekdays)
    }

    private func isSelected(_ option: Schedule.Weekdays) -> Binding<Bool> {
        Binding(
            get: {
                weekdays.contains(option)
            },
            set: { isOn in
                if isOn {
                    weekdays.insert(option)
                } else {
                    weekdays.remove(option)
                }
            }
        )
    }
}

extension Schedule {
    fileprivate var weekdays: Weekdays {
        get {
            if case let .weekly(weekdays, _, _) = self {
                weekdays
            } else {
                []
            }
        }
        set {
            if case let .weekly(_, interval, anchor) = self {
                self = .weekly(weekdays: newValue, interval: interval, anchor: anchor)
            }
        }
    }

    fileprivate var interval: Int {
        get {
            switch self {
            case let .weekly(_, interval, _), let .daily(interval, _): interval
            }
        }
        set {
            switch self {
            case let .weekly(weekdays, _, anchor): self = .weekly(weekdays: weekdays, interval: newValue, anchor: anchor)
            case let .daily(_, anchor): self = .daily(interval: newValue, anchor: anchor)
            }
        }
    }

    fileprivate var anchor: Date {
        get {
            switch self {
            case let .weekly(_, _, anchor), let .daily(_, anchor): anchor
            }
        }
        set {
            switch self {
            case let .weekly(weekdays, interval, _): self = .weekly(weekdays: weekdays, interval: interval, anchor: newValue)
            case let .daily(interval, _): self = .daily(interval: interval, anchor: newValue)
            }
        }
    }
}

#Preview("Weekly") {
    @Previewable @State
    var schedule: Schedule = .weekly()

    ScheduleEditor($schedule)
        .padding()
}

#Preview("Daily") {
    @Previewable @State
    var schedule: Schedule = .daily()

    ScheduleEditor($schedule)
        .padding()
}
