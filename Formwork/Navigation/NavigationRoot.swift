//
//  NavigationRoot.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 05.10.26.
//

import FormworkKit
import SwiftUI

struct NavigationRoot<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .navigationDestination(for: Route.self) { route in
                    route
                }
                .navigationDestination(for: Exercise.Category.self) { category in
                    ExerciseCategoryScreen(category)
                }
                .navigationDestination(for: Exercise.self) { exercise in
                    ExerciseScreen(exercise)
                }
                .navigationDestination(for: Workout.self) { workout in
                    WorkoutScreen(workout)
                }
                .navigationDestination(for: WorkoutEntry.self) { entry in
                    WorkoutEntryScreen(entry)
                }
                .navigationDestination(for: Session.self) { session in
                    SessionScreen(session)
                }
        }
        .safariPresenter()
    }
}
