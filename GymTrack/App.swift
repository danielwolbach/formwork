//
//  GymTrackApp.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

@main
struct GymTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Wrokouts", systemImage: "clipboard") {
                NavigationStack {
                    ContentUnavailableView("Workouts", systemImage: "clipboard")
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
}

