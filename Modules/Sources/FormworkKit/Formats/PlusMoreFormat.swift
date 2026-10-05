//
//  PlusMoreFormat.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 05.10.26.
//

import Foundation

public struct PlusMoreFormat: FormatStyle {
    public init() {
        // Nothing to initialize.
    }

    public func format(_ count: Int) -> String {
        .init(localized: .formatPlusMoreScheme(count: count))
    }
}

extension FormatStyle where Self == PlusMoreFormat {
    public static var plusMore: PlusMoreFormat {
        PlusMoreFormat()
    }
}
