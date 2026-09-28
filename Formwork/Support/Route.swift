//
//  Route.swift
//  Formwork
//
//  Created by Daniel Wolbach on 20.09.26.
//

import FormworkKit
import SwiftUI

enum Route: Hashable, View {
    case sessions

    var body: some View {
        switch self {
        case .sessions: SessionListScreen()
        }
    }
}
