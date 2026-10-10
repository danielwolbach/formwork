//
//  CalendarSection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct CalendarSection: View {
    private static let spacing: CGFloat = 8

    private static let cardPadding: CGFloat = 16

    private static let monthsAhead = 12

    @Environment(\.calendar)
    private var calendar: Calendar

    @Environment(\.statistics)
    private var statistics: Statistics

    @Query(filter: #Predicate<Workout> { !$0.isArchived })
    private var workouts: [Workout]

    @State
    private var selection: Date = .now

    @State
    private var month: Date?

    @State
    private var isTurningPage: Bool = false

    var body: some View {
        let months = months
        let lastSessions = lastSessions
        let shownMonth = month ?? startOfMonth(.now)
        let selectedDay = calendar.startOfDay(for: selection)
        let finished = statistics.sessions(on: selection)

        SectionView(.fieldCalendarTitle, subtitle: subtitle(for: shownMonth)) {
            GroupBox {
                HStack(spacing: Self.spacing) {
                    ForEach(calendar.orderedWeekdays, id: \.self) { weekday in
                        Text(calendar.veryShortWeekdaySymbols[weekday - 1])
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                // A paging tab view doesn't size itself, so an empty six-week grid sets the height.
                sizingGrid
                    .hidden()
                    .overlay {
                        TabView(selection: $month) {
                            ForEach(months, id: \.self) { month in
                                monthGrid(month, lastSessions: lastSessions)
                                    .padding(.horizontal, Self.cardPadding)
                                    .tag(Optional(month))
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        // Reaches out to the card's edges, so months slide out there instead of at the content's inset.
                        .padding(.horizontal, -Self.cardPadding)
                    }
                    .sensoryFeedback(.selection, trigger: selection)

                Divider()

                // Stacked, so the outgoing and incoming day crossfade in place instead of sitting below each other.
                ZStack(alignment: .top) {
                    CalendarDayList(day: selection, sessions: finished, planned: planned(on: selection, after: lastSessions))
                        .id(selectedDay)
                        .transition(.blurReplace)
                }
                .animation(.snappy, value: selectedDay)
            }
            .groupBoxStyle(.card)
        } accessory: {
            HStack {
                if !calendar.isDateInToday(selection) {
                    Button(.today) {
                        turnPage(to: startOfMonth(.now), selecting: .now)
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glass)
                    .transition(.blurReplace)
                }

                Button(.backward) {
                    showMonth(by: -1, from: shownMonth)
                }
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .disabled(shownMonth <= months.first ?? shownMonth)

                Button(.forward) {
                    showMonth(by: 1, from: shownMonth)
                }
                .labelStyle(.fixedIconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .disabled(shownMonth >= months.last ?? shownMonth)
            }
            .animation(.snappy, value: calendar.isDateInToday(selection))
        }
        .onAppear {
            month = month ?? startOfMonth(.now)
        }
        .onChange(of: month) { _, month in
            guard let month, !isTurningPage else {
                return
            }

            // Every page already shows this day as selected, so nothing swaps once a swipe settles.
            selection = sameDay(as: selection, in: month)
        }
    }

    private var sizingGrid: some View {
        Grid(horizontalSpacing: Self.spacing, verticalSpacing: Self.spacing) {
            ForEach(0 ..< 6, id: \.self) { _ in
                GridRow {
                    ForEach(0 ..< 7, id: \.self) { _ in
                        CalendarCell()
                    }
                }
            }
        }
    }

    private var months: [Date] {
        let current = startOfMonth(.now)
        let first = statistics.sessions.last.map { startOfMonth($0.startDate) }.map { min($0, current) } ?? current
        let count = calendar.dateComponents([.month], from: first, to: current).month ?? 0

        return (0 ... count + Self.monthsAhead).compactMap { calendar.date(byAdding: .month, value: $0, to: first) }
    }

    private var lastSessions: [Workout: Date] {
        workouts.reduce(into: [:]) { $0[$1] = statistics.lastSession(of: $1) }
    }

    private func monthGrid(_ month: Date, lastSessions: [Workout: Date]) -> some View {
        let selected = sameDay(as: selection, in: month)

        return Grid(horizontalSpacing: Self.spacing, verticalSpacing: Self.spacing) {
            ForEach(weeks(of: month), id: \.first) { week in
                GridRow {
                    ForEach(week, id: \.self) { day in
                        if calendar.isDate(day, equalTo: month, toGranularity: .month) {
                            let completed = completed(among: statistics.sessions(on: day))

                            Button {
                                selection = day
                            } label: {
                                CalendarDay(
                                    day: day,
                                    isSelected: calendar.isDate(day, inSameDayAs: selected),
                                    completed: completed,
                                    planned: planned(on: day, after: lastSessions)
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            CalendarDay(day: day, isOutsideMonth: true)
                        }
                    }
                }
            }
        }
    }

    private func subtitle(for month: Date) -> String {
        let isThisYear = calendar.isDate(month, equalTo: .now, toGranularity: .year)
        return month.formatted(isThisYear ? .dateTime.month(.wide) : .dateTime.month(.wide).year())
    }

    private func startOfMonth(_ date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    private func weeks(of month: Date) -> [[Date]] {
        let leading = (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7
        let days = (0 ..< 42).compactMap { calendar.date(byAdding: .day, value: $0 - leading, to: month) }
        return stride(from: 0, to: days.count, by: 7).map { Array(days[$0 ..< min($0 + 7, days.count)]) }
    }

    private func completed(among sessions: [Session]) -> [Workout] {
        Set(sessions.compactMap(\.workout)).sorted(using: SortDescriptor(\.name, comparator: .localizedStandard))
    }

    private func planned(on day: Date, after lastSessions: [Workout: Date]) -> [Workout] {
        guard calendar.startOfDay(for: day) >= calendar.startOfDay(for: .now) else {
            return []
        }

        return workouts
            .filter { $0.schedule.isDue(on: day, after: lastSessions[$0], in: calendar) }
            .sorted(using: SortDescriptor(\.name, comparator: .localizedStandard))
    }

    private func showMonth(by offset: Int, from month: Date) {
        guard let target = calendar.date(byAdding: .month, value: offset, to: month) else {
            return
        }

        turnPage(to: target, selecting: sameDay(as: selection, in: target))
    }

    private func turnPage(to target: Date, selecting day: Date) {
        guard target != month else {
            selection = day
            return
        }

        isTurningPage = true
        withAnimation {
            month = target
        } completion: {
            isTurningPage = false
            selection = day
        }
    }

    private func sameDay(as date: Date, in month: Date) -> Date {
        guard !calendar.isDate(date, equalTo: month, toGranularity: .month) else {
            return date
        }

        let day = calendar.component(.day, from: date)
        let count = calendar.range(of: .day, in: .month, for: month)?.count ?? 1
        return calendar.date(byAdding: .day, value: min(day, count) - 1, to: month) ?? month
    }
}

private struct CalendarCell: View {
    var body: some View {
        Color.clear
            .aspectRatio(0.8, contentMode: .fit)
    }
}

private struct CalendarDay: View {
    let day: Date

    var isSelected: Bool = false

    var isOutsideMonth: Bool = false

    var completed: [Workout] = []

    var planned: [Workout] = []

    @Environment(\.calendar)
    private var calendar: Calendar

    var body: some View {
        CalendarCell()
            .overlay(alignment: .top) {
                VStack(spacing: 4) {
                    // Each layer keeps a fixed style and only fades, since styles of different kinds can't be interpolated.
                    Circle()
                        .fill(isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.gray))
                        .opacity(isSelected ? 1 : 0)
                        .overlay {
                            ZStack {
                                number
                                    .fontWeight(isToday ? .semibold : .regular)
                                    .foregroundStyle(foreground)
                                    .opacity(isSelected ? 0 : 1)

                                number
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(.systemBackground))
                                    .opacity(isSelected ? 1 : 0)
                            }
                        }

                    HStack(spacing: 4) {
                        ForEach(markers, id: \.workout.id) { marker in
                            CalendarMarker(color: marker.workout.pictogram.color, isCompleted: marker.isCompleted)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .contentShape(.rect)
            .animation(.snappy(duration: 0.1), value: isSelected)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(day, format: .dateTime.weekday(.wide).day().month(.wide)))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityHidden(isOutsideMonth)
    }

    private var number: some View {
        Text(day, format: .dateTime.day())
            .font(.subheadline.monospacedDigit())
    }

    private var markers: [(workout: Workout, isCompleted: Bool)] {
        Array((completed.map { ($0, true) } + planned.map { ($0, false) }).prefix(3))
    }

    private var isToday: Bool {
        calendar.isDateInToday(day) && !isOutsideMonth
    }

    private var foreground: AnyShapeStyle {
        if isOutsideMonth {
            AnyShapeStyle(.tertiary)
        } else if isToday {
            AnyShapeStyle(.tint)
        } else {
            AnyShapeStyle(.primary)
        }
    }
}

private struct CalendarMarker: View {
    let color: Color

    let isCompleted: Bool

    var body: some View {
        Group {
            if isCompleted {
                Circle()
                    .fill(color)
            } else {
                Circle()
                    .strokeBorder(color, lineWidth: 1.5)
            }
        }
        .frame(width: 8, height: 8)
    }
}

private struct CalendarDayList: View {
    let day: Date

    let sessions: [Session]

    let planned: [Workout]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(day, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)

            if sessions.isEmpty, planned.isEmpty {
                Text(.emptyWorkoutsTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .padding(.vertical, 8)
            }

            ForEach(sessions) { session in
                row(linkingTo: session) {
                    PictogramRow(
                        session.pictogram,
                        title: session.title,
                        subtitle: session.startDate.formatted(session.wallClockTime()),
                        badge: .completedBadge
                    )
                }
            }

            ForEach(planned) { workout in
                row(linkingTo: workout) {
                    PictogramRow(workout.pictogram, title: workout.title, subtitle: workout.formatted(.workoutDetails), badge: .pendingBadge)
                }
            }
        }
    }

    private func row(linkingTo value: some Hashable, @ViewBuilder label: () -> some View) -> some View {
        NavigationLink(value: value) {
            label()

            Image(systemName: "chevron.forward")
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationRoot {
        ScrollView {
            CalendarSection()
        }
    }
    .sampleData()
}
