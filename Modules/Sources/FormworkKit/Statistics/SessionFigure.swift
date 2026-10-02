//
//  SessionFigure.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

/// Something one session has. Unlike a statistic it describes a session, not a stretch of time.
public protocol SessionFigure {
    static var info: String {
        get
    }

    static var pictogram: Pictogram {
        get
    }

    static var title: String {
        get
    }

    var reading: Reading? {
        get
    }

    init(_ session: Session, calendar: Calendar)

    init(typicalOf sessions: [Session], calendar: Calendar)
}

extension SessionFigure {
    public init(_ session: Session) {
        self.init(session, calendar: .current)
    }
}

public protocol SessionMeasure: SessionFigure {
    static var tolerance: Double? {
        get
    }

    var value: Double? {
        get
    }

    init(value: Double?)

    static func value(of session: Session) -> Double?

    func reading(of value: Double) -> Reading
}

extension SessionMeasure {
    public init(_ session: Session, calendar _: Calendar) {
        self.init(value: Self.value(of: session))
    }

    public init(typicalOf sessions: [Session], calendar _: Calendar) {
        self.init(value: sessions.compactMap(Self.value(of:)).median)
    }

    public static var tolerance: Double? {
        0.05
    }

    public var reading: Reading? {
        value.map(reading(of:))
    }
}
