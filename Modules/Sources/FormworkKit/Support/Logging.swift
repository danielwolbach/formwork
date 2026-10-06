//
//  Logging.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 06.10.26.
//

import OSLog

extension Logger {
    private static let subsystem = "de.danielwolbach.Formwork"

    public static let health = Logger(subsystem: subsystem, category: "Health")
}
