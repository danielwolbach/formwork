//
//  SessionFigureKind.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public enum SessionFigureKind: CaseIterable, Sendable {
    case duration
    case endTime
    case skipRate
    case exerciseDuration
    case completedExercises
    case volume
}

extension SessionFigureKind: Identifiable {
    public var id: Self {
        self
    }
}

extension SessionFigureKind {
    public var figure: any SessionFigure.Type {
        switch self {
        case .duration: SessionDuration.self
        case .endTime: SessionEndTime.self
        case .skipRate: SessionSkipRate.self
        case .exerciseDuration: SessionExerciseDuration.self
        case .completedExercises: SessionCompletedExercises.self
        case .volume: SessionVolume.self
        }
    }
}
