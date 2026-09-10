//
//  Route.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import SwiftUI

enum Route: Hashable, View {
    case sessions

    var body: some View {
        switch self {
        case .sessions: SessionListScreen()
        }
    }
}
