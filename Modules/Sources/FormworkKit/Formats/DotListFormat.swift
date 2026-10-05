//
//  DotListFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public struct DotListFormat: FormatStyle {
    public init() {
        // Nothing to initialize.
    }

    public func format(_ parts: [String]) -> String {
        parts.filter { !$0.isEmpty }.joined(separator: " · ")
    }
}

extension FormatStyle where Self == DotListFormat {
    public static var dotList: DotListFormat {
        DotListFormat()
    }
}
