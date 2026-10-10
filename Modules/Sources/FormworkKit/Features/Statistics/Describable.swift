//
//  Describable.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public protocol Describable {
    var title: String { get }

    var info: String { get }

    var pictogram: Pictogram { get }
}
