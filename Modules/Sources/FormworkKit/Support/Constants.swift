//
//  Constants.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation

public enum DeepLink {
    public static let scheme = "formwork"

    public static let session = URL(string: "\(scheme)://session")!
}

public enum AppGroup {
    public static let identifier = "group.de.danielwolbach.Formwork"

    public static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier)!
    }
}

/// Keys must not contain dots: `@AppStorage` observes them with KVO, which reads a dot as a key path and never fires.
public enum StorageKeys {
    public static let onboardingPending = "onboardingPending"

    public static let weightSystem = "unitsWeight"

    public static let distanceSystem = "unitsDistance"
}

public enum WidgetKind {
    public static let overview = "OverviewWidget"

    public static let weekStreak = "WeekStreakWidget"
}
