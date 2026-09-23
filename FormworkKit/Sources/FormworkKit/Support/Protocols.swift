//
//  Protocols.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 23.09.26.
//

import Foundation

public protocol Displayable {
    var pictogram: Pictogram {
        get
    }

    var title: String {
        get
    }

    var subtitle: String? {
        get
    }
}

extension Displayable {
    public var subtitle: String? {
        nil
    }
}

public protocol Rankable {
    var rank: Double {
        get
    }

    var symbol: String {
        get
    }

    func label(for rank: Double) -> String
}
