//
//  Extensions.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftUI

extension GridItem {
    static func ntile(n: Int, spacing: CGFloat? = nil) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: n)
    }
}
