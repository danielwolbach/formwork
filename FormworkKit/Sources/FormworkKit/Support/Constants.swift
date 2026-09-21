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

public enum StorageKeys {
    public static let onboardingPending = "onboarding.pending"
}
