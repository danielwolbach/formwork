//
//  Displayable.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 23.09.26.
//

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
