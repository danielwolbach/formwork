//
//  Exercise.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

enum Samples {
    static let exercises: [Exercise] =
    [
        Exercise(name: "Cross Trainer", type: .duration, categories: [.cardio, .legs]),
        Exercise(name: "Leg Press", type: .weight, categories: [.legs]),
        Exercise(name: "Chest Press", type: .weight, categories: [.chest, .arms]),
        Exercise(name: "Lat Pulldown", type: .weight, categories: [.back, .arms]),
        Exercise(name: "Leg Curl", type: .weight, categories: [.legs]),
        Exercise(name: "Shoulder Press", type: .weight, categories: [.shoulders, .arms]),
        Exercise(name: "Rowing Machine", type: .weight, categories: [.back, .arms]),
        Exercise(name: "Abdominal Machine", type: .weight, categories: [.core]),
        Exercise(name: "Hyperextensions", type: .bodyweight, categories: [.back]),
        Exercise(name: "Bicep Curl", type: .weight, categories: [.arms]),
        Exercise(name: "Tricep Pushdown", type: .weight, categories: [.arms]),
        Exercise(name: "Squat", type: .weight, categories: [.legs]),
        Exercise(name: "Deadlift", type: .weight, categories: [.legs, .back]),
        Exercise(name: "Bench Press", type: .weight, categories: [.chest]),
        Exercise(name: "Incline Dumbbell Press", type: .weight, categories: [.chest, .shoulders]),
        Exercise(name: "Lateral Raise", type: .weight, categories: [.shoulders]),
        Exercise(name: "Pull-Up", type: .bodyweight, categories: [.back, .arms]),
        Exercise(name: "Push-Up", type: .bodyweight, categories: [.chest, .arms]),
        Exercise(name: "Plank", type: .duration, categories: [.core]),
        Exercise(name: "Russian Twist", type: .bodyweight, categories: [.core]),
        Exercise(name: "Treadmill Run", type: .distance, categories: [.cardio, .legs]),
        Exercise(name: "Cycling", type: .distance, categories: [.cardio, .legs]),
        Exercise(name: "Jump Rope", type: .duration, categories: [.cardio, .legs]),
        Exercise(name: "Sun Salutation", type: .duration, categories: [.flexibility, .mindfulness]),
        Exercise(name: "Hamstring Stretch", type: .duration, categories: [.flexibility, .legs]),
        Exercise(name: "Box Breathing", type: .duration, categories: [.mindfulness]),
        Exercise(name: "Farmer's Carry", type: .weight, categories: [.arms, .core, .other]),
    ]
    
    static let fullBodyEntries: [WorkoutEntry] =
    [
        WorkoutEntry(order: 0, exercise: exercises[0], target: .duration(minutes: 10)),
        WorkoutEntry(order: 1, exercise: exercises[1], target: .weight(weight: 85, sets: 3, reps: 10)),
        WorkoutEntry(order: 2, exercise: exercises[2], target: .weight(weight: 40, sets: 3, reps: 10)),
        WorkoutEntry(order: 3, exercise: exercises[3], target: .weight(weight: 40, sets: 3, reps: 10)),
        WorkoutEntry(order: 4, exercise: exercises[4], target: .weight(weight: 40, sets: 3, reps: 12)),
        WorkoutEntry(order: 5, exercise: exercises[5], target: .weight(weight: 25, sets: 3, reps: 12)),
        WorkoutEntry(order: 6, exercise: exercises[6], target: .weight(weight: 45, sets: 3, reps: 12)),
        WorkoutEntry(order: 7, exercise: exercises[7], target: .weight(weight: 40, sets: 3, reps: 14)),
        WorkoutEntry(order: 8, exercise: exercises[8], target: .bodyweight(sets: 3, reps: 12)),
    ]

    static let pushDayEntries: [WorkoutEntry] =
    [
        WorkoutEntry(order: 0, exercise: exercises[13], target: .weight(weight: 60, sets: 4, reps: 8)),
        WorkoutEntry(order: 1, exercise: exercises[14], target: .weight(weight: 22.5, sets: 3, reps: 10)),
        WorkoutEntry(order: 2, exercise: exercises[5], target: .weight(weight: 20, sets: 3, reps: 12)),
        WorkoutEntry(order: 3, exercise: exercises[15], target: .weight(weight: 8, sets: 3, reps: 15)),
        WorkoutEntry(order: 4, exercise: exercises[10], target: .weight(weight: 25, sets: 3, reps: 12)),
        WorkoutEntry(order: 5, exercise: exercises[17], target: .bodyweight(sets: 3, reps: 15)),
    ]

    static let legDayEntries: [WorkoutEntry] =
    [
        WorkoutEntry(order: 0, exercise: exercises[22], target: .duration(minutes: 5)),
        WorkoutEntry(order: 1, exercise: exercises[11], target: .weight(weight: 70, sets: 4, reps: 8)),
        WorkoutEntry(order: 2, exercise: exercises[12], target: .weight(weight: 80, sets: 3, reps: 6)),
        WorkoutEntry(order: 3, exercise: exercises[1], target: .weight(weight: 100, sets: 3, reps: 10)),
        WorkoutEntry(order: 4, exercise: exercises[4], target: .weight(weight: 35, sets: 3, reps: 12)),
        WorkoutEntry(order: 5, exercise: exercises[24], target: .duration(minutes: 5)),
    ]
    
    static let scheduleAnchor: Date = {
        let calendar = Calendar.autoupdatingCurrent
        let anchor = calendar.date(byAdding: .day, value: -35, to: .now) ?? .now
        return calendar.startOfDay(for: anchor)
    }()

    static let workouts: [Workout] =
    [
        Workout(
            name: "Full Body",
            pictogram: Pictogram(icon: "figure.strengthtraining.traditional", tint: .blue),
            entries: Samples.fullBodyEntries,
            schedule: Schedule(
                days: Set(Weekday.allCases),
                interval: 1,
                startDate: Samples.scheduleAnchor
            )
        ),
        Workout(
            name: "Push Day",
            pictogram: Pictogram(icon: "figure.boxing", tint: .orange),
            entries: Samples.pushDayEntries,
            schedule: Schedule(
                days: [.monday, .thursday],
                interval: 1,
                startDate: Samples.scheduleAnchor
            )
        ),
        Workout(
            name: "Leg Day",
            pictogram: Pictogram(icon: "figure.strengthtraining.functional", tint: .purple),
            entries: Samples.legDayEntries,
            schedule: Schedule(
                days: [.tuesday, .saturday],
                interval: 2,
                startDate: Samples.scheduleAnchor
            )
        ),
    ]
    
    static let workoutEntries: [WorkoutEntry] = fullBodyEntries
    
    static let session: Session = {
        try! Session.start(workouts[0], in: container.mainContext)
    }()
}

extension Samples {
    private struct SessionPlan {
        let weeksAgo: Int
        let weekday: Weekday
        let workout: Int
        var skipsLast: Bool = false
        var isAbandoned: Bool = false
    }

    private static let historyWeeks = 12

    private static let gapWeek = 6

    private static let entryDuration: TimeInterval = 5 * 60

    private static var sessionPlans: [SessionPlan] {
        var plans: [SessionPlan] = []

        for weeksAgo in 0 ..< historyWeeks where weeksAgo != gapWeek {
            plans.append(SessionPlan(weeksAgo: weeksAgo, weekday: .monday, workout: 1))
            plans.append(SessionPlan(weeksAgo: weeksAgo, weekday: .thursday, workout: 1, skipsLast: weeksAgo.isMultiple(of: 3)))
            plans.append(SessionPlan(weeksAgo: weeksAgo, weekday: .saturday, workout: 0))

            if weeksAgo.isMultiple(of: 2) {
                plans.append(SessionPlan(weeksAgo: weeksAgo, weekday: .tuesday, workout: 2))
            }
        }

        plans.append(SessionPlan(weeksAgo: 2, weekday: .wednesday, workout: 0, isAbandoned: true))

        return plans
    }

    static func insertHistory(into context: ModelContext) {
        let calendar = Calendar.autoupdatingCurrent

        guard let currentWeek = calendar.weekStart(for: .now) else {
            return
        }

        for plan in sessionPlans.sorted(by: { $0.weeksAgo > $1.weeksAgo }) {
            guard
                let week = calendar.date(byAdding: .weekOfYear, value: -plan.weeksAgo, to: currentWeek),
                let day = calendar.date(byAdding: .day, value: plan.weekday.rawValue, to: week),
                let start = calendar.date(bySettingHour: hour(for: plan.workout), minute: 15, second: 0, of: day),
                start < .now
            else {
                continue
            }

            insert(plan, startingAt: start, into: context)
        }
    }

    private static func hour(for workout: Int) -> Int {
        switch workout {
        case 1: 7   // Push Day, before work
        case 2: 19  // Leg Day, late
        default: 18 // Full Body, after work
        }
    }

    private static func insert(_ plan: SessionPlan, startingAt start: Date, into context: ModelContext) {
        let session = try! Session.start(workouts[plan.workout], in: context)
        let entries = session.entries.sorted()

        session.started = start

        var moment = start

        for entry in entries {
            moment.addTimeInterval(entryDuration)

            let isSkipped = plan.isAbandoned || (plan.skipsLast && entry === entries.last)
            entry.status = isSkipped ? .skipped(at: moment) : .completed(at: moment)
        }

        session.ended = moment.addingTimeInterval(entryDuration)
    }
}


extension Samples {
    static let container: ModelContainer = {
        let schema = Schema([Exercise.self, Workout.self, WorkoutEntry.self, Session.self, SessionEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        
        Samples.exercises.forEach(container.mainContext.insert)
        Samples.workouts.forEach(container.mainContext.insert)
        Samples.insertHistory(into: container.mainContext)
      
        return container
    }()
}

extension Samples {
    static var finishedSessions: [Session] {
        (try? container.mainContext.fetch(Session.finishedDescriptor)) ?? []
    }

    static var stats: Stats {
        finishedSessions.stats()
    }
}

private struct SampleDataModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .modelContainer(Samples.container)
    }
}

extension View {
    func sampleData() -> some View {
        modifier(SampleDataModifier())
    }
}
