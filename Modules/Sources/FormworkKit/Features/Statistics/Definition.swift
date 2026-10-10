//
//  Definition.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public struct Definition<Value> {
    public let pictogram: Pictogram

    let value: Value

    private let titleResource: LocalizedStringResource

    private let infoResource: LocalizedStringResource

    init(title: LocalizedStringResource, info: LocalizedStringResource, pictogram: Pictogram, value: Value) {
        self.pictogram = pictogram
        self.value = value
        self.titleResource = title
        self.infoResource = info
    }
}

extension Definition {
    public var title: String {
        String(localized: titleResource)
    }

    public var info: String {
        String(localized: infoResource)
    }
}
