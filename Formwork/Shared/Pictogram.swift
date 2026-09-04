//
//  Pictogram.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct Pictogram {
    var icon: String
    
    var color: Color
}

extension Pictogram {
    static let unknown = Pictogram(icon: "questionmark", color: .gray)
}
