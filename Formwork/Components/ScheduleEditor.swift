//
//  ScheduleEditor.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ScheduleEditor: View {
    private enum Rhythm: Hashable {
        case weekly, daily
    }

    private static let dayIntervals = 1 ... 28

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
        VStack(spacing: .groups) {
            rhythmPicker

            Divider()

            Group {
                switch schedule {
                case .weekly: weeklyScheduleEditor
                case .daily: dailyScheduleEditor
                }
            }
            .transition(.blurReplace)
        }
        .animation(.snappy, value: schedule)
        .labeledContentStyle(.row)
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
        VStack(spacing: .groups) {
            WeekdayPicker(weekdays, calendar: calendar)

            // A weekly schedule without weekdays is inactive, so there's nothing to start yet.
            if !schedule.weekdays.isEmpty {
                Divider()

                anchorPicker
            }
        }
    }

    private var dailyScheduleEditor: some View {
        VStack(spacing: .groups) {
            stepper(
                Text(.fieldRhythmDailyIntervalTitle(count: schedule.days)),
                value: $schedule.days,
                range: Self.dayIntervals
            )

            Divider()

            anchorPicker
        }
    }

    private var anchorPicker: some View {
        LabeledContent {
            DateButton(.fieldStartDateTitle, date: $schedule.anchor)
        } label: {
            Text(.fieldStartDateTitle)
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
                case let (.weekly(_, anchor), .daily):
                    schedule = .daily(anchor: schedule.weekdays.isEmpty ? .now : anchor)
                case let (.daily(_, anchor), .weekly):
                    schedule = .weekly(anchor: anchor)
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

    private func stepper(_ title: Text, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        LabeledContent {
            Button(.decrease) {
                value.wrappedValue -= 1
            }
            .buttonStyle(.card)
            .labelStyle(.fixedIconOnly)
            .disabled(value.wrappedValue <= range.lowerBound)

            Button(.increase) {
                value.wrappedValue += 1
            }
            .buttonStyle(.card)
            .labelStyle(.fixedIconOnly)
            .disabled(value.wrappedValue >= range.upperBound)
        } label: {
            title
                .contentTransition(.opacity)
        }
        .sensoryFeedback(.selection, trigger: value.wrappedValue)
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
            ForEach(calendar.orderedWeekdays, id: \.self) { weekday in
                let option = Schedule.Weekdays(calendarWeekday: weekday)

                Button {
                    weekdays.formSymmetricDifference(option)
                } label: {
                    Text(calendar.veryShortWeekdaySymbols[weekday - 1])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(CardButtonStyle(style: weekdays.contains(option) ? .selected : .bordered))
                .buttonBorderShape(.circle)
                .aspectRatio(1, contentMode: .fit)
                .accessibilityLabel(calendar.weekdaySymbols[weekday - 1])
            }
        }
        .sensoryFeedback(.selection, trigger: weekdays)
    }
}

extension Schedule {
    fileprivate var weekdays: Weekdays {
        get {
            if case let .weekly(weekdays, _) = self {
                weekdays
            } else {
                []
            }
        }
        set {
            if case let .weekly(_, anchor) = self {
                self = .weekly(weekdays: newValue, anchor: anchor)
            }
        }
    }

    fileprivate var days: Int {
        get {
            if case let .daily(days, _) = self {
                days
            } else {
                1
            }
        }
        set {
            if case let .daily(_, anchor) = self {
                self = .daily(days: newValue, anchor: anchor)
            }
        }
    }

    fileprivate var anchor: Date {
        get {
            switch self {
            case let .weekly(_, anchor), let .daily(_, anchor): anchor
            }
        }
        set {
            switch self {
            case let .weekly(weekdays, _): self = .weekly(weekdays: weekdays, anchor: newValue)
            case let .daily(days, _): self = .daily(days: days, anchor: newValue)
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
