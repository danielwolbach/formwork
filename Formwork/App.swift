//
//  App.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

@main struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            AppContent()
                .sampleData()
        }
    }
}

private struct AppContent: View {
    var body: some View {
        TabView {
            Tab(.screenWorkoutsTitle, systemImage: "clipboard") {
                NavigationStack {
                    WorkoutsScreen()
                }
            }
            
            Tab(.screenCatalogTitle, systemImage: "magazine") {
                NavigationStack {
                    CatalogScreen()
                }
            }
        }
    }
}

#Preview {
    AppContent()
        .sampleData()
}
