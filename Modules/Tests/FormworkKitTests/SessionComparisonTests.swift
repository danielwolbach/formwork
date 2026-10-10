//
//  SessionComparisonTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 02.10.26.
//

@testable import FormworkKit
import Foundation
import Testing

@MainActor
struct SessionComparisonTests {
    let store: TestStore

    let calendar = Calendar.berlin()

    init() throws {
        self.store = try TestStore()
    }

    func compare(_ session: Session, as quantity: Quantity = .duration) -> Comparison {
        Comparison(quantity, of: session, among: store.sessions, calendar: calendar)
    }

    @Test
    func baselineIsTheWorkoutsSessionsOfTheDaysBefore() throws {
        try store.session(1, minutes: 20)
        try store.session(2, minutes: 30)
        try store.session(3, minutes: 40)
        try store.session(10, hour: 6, minutes: 10)
        let session = try store.session(10, hour: 18, minutes: 60)

        let comparison = compare(session)

        // An earlier session on the same day would pull the median down to 25 minutes.
        #expect(comparison.current == .duration(seconds: 60 * 60))
        #expect(comparison.typical == .duration(seconds: 30 * 60))
        #expect(comparison.direction == .up)
    }

    @Test
    func baselineNeedsThreeSessions() throws {
        try store.session(1, minutes: 20)
        try store.session(2, minutes: 30)
        let session = try store.session(10, minutes: 60)

        #expect(compare(session).typical == nil)
        #expect(compare(session).direction == nil)
    }

    @Test
    func baselineNeedsThreeValues() throws {
        for (day, kilograms) in [(1, 120.0), (2, 130), (3, nil)] {
            try store.session(day, kilograms: kilograms)
        }

        let session = try store.session(10, kilograms: 140)

        #expect(compare(session, as: .volume).typical == nil)

        try store.session(4, kilograms: 125)

        #expect(compare(session, as: .volume).typical == .weight(kilograms: 1250))
    }

    @Test
    func baselineLeavesOutOtherWorkouts() throws {
        let legs = Workout(name: "Legs", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(legs)

        for day in 1 ... 3 {
            let other = try #require(legs.startSession())
            other.startDate = try calendar.date(day, hour: 8)
            other.endDate = other.startDate.addingTimeInterval(600)
        }

        let session = try store.session(10, minutes: 60)

        #expect(compare(session).typical == nil)
    }

    @Test
    func pointsEndWithTheSession() throws {
        try store.session(1, month: 8)
        try store.session(2, month: 8)
        try store.session(1)
        try store.session(2)
        try store.session(3)
        let session = try store.session(10)
        try store.session(12)

        let points = try #require(Series(.duration, endingWith: session, among: store.sessions, count: 5, calendar: calendar)).points

        #expect(try points.map(\.date) == [8, 9, 9, 9, 9].enumerated().map { index, month in
            try calendar.date([2, 1, 2, 3, 10][index], month: month, hour: 8)
        })
        #expect(points.map(\.isHighlighted) == [false, false, false, false, true])
    }

    @Test
    func endTimeHasABaselineButNoDirection() throws {
        try store.session(1, hour: 8, minutes: 60)
        try store.session(2, hour: 8, minutes: 60)
        try store.session(3, hour: 8, minutes: 60)
        let session = try store.session(10, hour: 18, minutes: 60)

        let comparison = compare(session, as: .endTime)

        #expect(comparison.current == Reading(19 * 60, as: .time(calendar)))
        #expect(comparison.typical == Reading(9 * 60, as: .time(calendar)))
        #expect(comparison.direction == nil)
        #expect(Series(.endTime, endingWith: session, among: store.sessions, calendar: calendar) == nil)
    }
}
