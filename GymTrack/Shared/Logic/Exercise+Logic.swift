//
//  Exercise+Logic.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 13.07.26.
//

import SwiftData

extension ModelContext {
    func deleteExercise(_ exercise: Exercise) throws {
        let sessions = try fetch(FetchDescriptor<Session>())

        for session in sessions {
            let remainingEntries = session.entries.sorted().filter { $0.exercise.id != exercise.id }

            if remainingEntries.isEmpty {
                delete(session)
            } else if session.current.exercise.id == exercise.id {
                session.current = remainingEntries[0]
            }
        }

        delete(exercise)
        try save()
    }
}
