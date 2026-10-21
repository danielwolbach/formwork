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

    public static let overview = URL(string: "\(scheme)://overview")!
}

public enum AppGroup {
    public static let identifier = "group.com.formworkfitness.Formwork"

    public static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier)!
    }
}

public enum StorageKeys {
    public static let onboardingPending = "onboardingPending"

    public static let weightSystem = "unitsWeight"

    public static let distanceSystem = "unitsDistance"

    public static let dailyReminder = "dailyReminder"

    public static let dailyReminderMinute = "dailyReminderMinute"

    public static let upcomingReminder = "upcomingReminder"
}

public enum WidgetKind {
    public static let overview = "OverviewWidget"

    public static let weekStreak = "WeekStreakWidget"
}

public enum LegalLinks {
    public static let terms = URL(string: String(localized: .linkLegalTerms))!

    public static let privacy = URL(string: String(localized: .linkLegalPrivacy))!
}

public enum AppMetadata {
    public static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Formwork"
    }

    public static var version: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
