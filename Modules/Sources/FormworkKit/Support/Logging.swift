//
//  Logging.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 06.10.26.
//

import OSLog

extension Logger {
    public static let health = Logger(subsystem: subsystem, category: "Health")

    public static let storage = Logger(subsystem: subsystem, category: "Storage")

    public static let session = Logger(subsystem: subsystem, category: "Session")

    public static let spotlight = Logger(subsystem: subsystem, category: "Spotlight")

    public static let paywall = Logger(subsystem: subsystem, category: "Paywall")

    public static let reminders = Logger(subsystem: subsystem, category: "Reminders")

    private static let subsystem = "de.danielwolbach.Formwork"
}
