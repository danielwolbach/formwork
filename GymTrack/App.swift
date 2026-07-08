//
//  App.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

@main
struct GymTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutEntry.self, Session.self, SessionEntry.self])
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Workouts", systemImage: "clipboard") {
                NavigationStack {
                    WorkoutListScreen()
                }
            }

            Tab("Catalog", systemImage: "magazine") {
                NavigationStack {
                    ContentUnavailableView("Catalog", systemImage: "magazine")
                }
            }

            Tab("Stats", systemImage: "sparkles") {
                NavigationStack {
                    ContentUnavailableView("Stats", systemImage: "sparkles")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .sampleData()
}
