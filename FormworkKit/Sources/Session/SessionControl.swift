//
//  SessionControl.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation

public protocol SessionControlling: Sendable {
    func complete() async

    func undo() async

    func moveToNext() async

    func moveToPrevious() async
}

@MainActor
public enum SessionControl {
    private static var controller: (any SessionControlling)?

    public static func register(_ controller: any SessionControlling) {
        Self.controller = controller
    }

    static func resolve() -> (any SessionControlling)? {
        controller
    }
}
