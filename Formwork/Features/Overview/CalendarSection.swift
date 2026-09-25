//
//  CalendarSection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 25.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct CalendarSection: View {
    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    @Query
    private var workouts: [Workout]

    @State
    private var month: Date = .now

    @State
    private var selectedDay: Int = Calendar.current.component(.day, from: .now)

    var body: some View {
        let sessionsInMonth = sessionsInMonth

        SectionView(.sectionOverviewCalendar, subtitle: subtitle) {
            VStack(spacing: 12) {
                LazyVGrid(columns: GridItem.ntile(n: 7, spacing: 0)) {
                    ForEach(Schedule.Weekday.ordered()) { weekday in
                        Text(weekday.symbol())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                LazyVGrid(columns: GridItem.ntile(n: 7, spacing: 0), spacing: 12) {
                    ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                        if let day {
                            let completed = completed(on: day, among: sessionsInMonth)

                            Button {
                                withAnimation(.snappy) {
                                    selectedDay = Calendar.current.component(.day, from: day)
                                }
                            } label: {
                                CalendarDay(
                                    day: day,
                                    isSelected: Calendar.current.isDate(day, inSameDayAs: selection),
                                    completed: completed,
                                    planned: planned(on: day, besides: completed)
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear
                        }
                    }
                }
                .sensoryFeedback(.selection, trigger: selectedDay)
                .padding(.bottom, 8)

                Divider()

                let finished = sessions(on: selection, among: sessionsInMonth)
                CalendarDayList(day: selection, sessions: finished, planned: planned(on: selection, besides: finished.compactMap(\.workout)))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
        } accessory: {
            // First, so appearing and disappearing doesn't move the arrows.
            if !isShowingToday {
                Button(.today) {
                    showToday()
                }
                .labelStyle(.fixedTitleAndIcon)
                .buttonStyle(.glass)
                .transition(.blurReplace)
            }

            Button(.backward) {
                showMonth(by: -1)
            }
            .labelStyle(.fixedIconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)

            Button(.forward) {
                showMonth(by: 1)
            }
            .labelStyle(.fixedIconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
    }

    private var subtitle: String {
        let calendar = Calendar.current
        let sameYear = calendar.isDate(month, equalTo: .now, toGranularity: .year)
        return month.formatted(sameYear ? .dateTime.month(.wide) : .dateTime.month(.wide).year())
    }

    private var days: [Date?] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }

        let leading = (calendar.component(.weekday, from: interval.start) - calendar.firstWeekday + 7) % 7
        let count = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        let days = (0 ..< count).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
        return Array(repeating: nil, count: leading) + days
    }

    private var selection: Date {
        let calendar = Calendar.current
        guard let start = calendar.dateInterval(of: .month, for: month)?.start else {
            return month
        }

        let count = calendar.range(of: .day, in: .month, for: month)?.count ?? 1
        return calendar.date(byAdding: .day, value: min(selectedDay, count) - 1, to: start) ?? start
    }

    private var isShowingToday: Bool {
        let calendar = Calendar.current
        return calendar.isDate(month, equalTo: .now, toGranularity: .month) && selectedDay == calendar.component(.day, from: .now)
    }

    private var sessionsInMonth: [Session] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }

        return sessions.filter { $0.falls(into: interval, in: calendar) }
    }

    private func sessions(on day: Date, among sessions: [Session]) -> [Session] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .day, for: day) else {
            return []
        }

        return sessions
            .filter { $0.falls(into: interval, in: calendar) }
            .sorted { $0.startDate < $1.startDate }
    }

    private func completed(on day: Date, among sessions: [Session]) -> [Workout] {
        let workouts = self.sessions(on: day, among: sessions).compactMap(\.workout)
        return Set(workouts).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// Only from today on: a workout keeps just its current schedule, so earlier days would show what it plans now,
    /// not what it planned then.
    private func planned(on day: Date, besides completed: [Workout]) -> [Workout] {
        let calendar = Calendar.current
        guard calendar.startOfDay(for: day) >= calendar.startOfDay(for: .now) else {
            return []
        }

        return workouts
            .filter { $0.schedule.isScheduled(on: day) && !completed.contains($0) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func showToday() {
        withAnimation(.snappy) {
            month = .now
            selectedDay = Calendar.current.component(.day, from: .now)
        }
    }

    private func showMonth(by offset: Int) {
        guard let month = Calendar.current.date(byAdding: .month, value: offset, to: month) else {
            return
        }

        withAnimation(.snappy) {
            self.month = month
        }
    }
}

private struct CalendarDay: View {
    let day: Date

    let isSelected: Bool

    let completed: [Workout]

    let planned: [Workout]

    var body: some View {
        let isToday = Calendar.current.isDateInToday(day)

        VStack(spacing: 4) {
            Text(day, format: .dateTime.day())
                .font(.subheadline.monospacedDigit())
                .fontWeight(isToday || isSelected ? .semibold : .regular)
                .foregroundStyle(foreground(isToday: isToday))
                .frame(width: 32, height: 32)
                .background {
                    if isSelected {
                        Circle()
                            .fill(isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                    }
                }

            HStack(spacing: 2) {
                ForEach(markers, id: \.workout.id) { workout, isCompleted in
                    CalendarMarker(color: workout.pictogram.color, isCompleted: isCompleted)
                        .frame(width: 7, height: 7)
                }
            }
            .frame(height: 7)
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(day, format: .dateTime.weekday(.wide).day().month(.wide)))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var markers: [(workout: Workout, isCompleted: Bool)] {
        Array((completed.map { ($0, true) } + planned.map { ($0, false) }).prefix(3))
    }

    private func foreground(isToday: Bool) -> AnyShapeStyle {
        if isSelected {
            AnyShapeStyle(Color(.systemBackground))
        } else if isToday {
            AnyShapeStyle(.tint)
        } else {
            AnyShapeStyle(.primary)
        }
    }
}

private struct CalendarDayList: View {
    let day: Date

    let sessions: [Session]

    let planned: [Workout]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            Text(day, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)

            if sessions.isEmpty, planned.isEmpty {
                // As tall as a row's pictogram, with the same spacing around it.
                Text(.sectionOverviewCalendarEmpty)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .padding(.vertical, 8)
                    .transition(.blurReplace)
            }

            ForEach(sessions) { session in
                link(to: session) {
                    PictogramRow(
                        pictogram: session.pictogram,
                        title: session.title,
                        subtitle: session.startDate.formatted(session.wallClockTime()),
                        badge: .completedBadge
                    )
                }
            }

            ForEach(planned) { workout in
                link(to: workout) {
                    PictogramRow(workout, badge: .pendingBadge)
                }
            }
        }
    }

    private func link(to value: some Hashable, @ViewBuilder label: () -> some View) -> some View {
        NavigationLink(value: value) {
            label()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .transition(.blurReplace)
    }
}

private struct CalendarMarker: View {
    let color: Color

    let isCompleted: Bool

    var body: some View {
        if isCompleted {
            Circle()
                .fill(color)
        } else {
            Circle()
                .strokeBorder(color, lineWidth: 1.5)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            CalendarSection()
        }
        .navigationDestination(for: Workout.self) { workout in
            WorkoutScreen(workout: workout)
        }
        .navigationDestination(for: Session.self) { session in
            SessionScreen(session: session)
        }
    }
    .sampleData()
}
