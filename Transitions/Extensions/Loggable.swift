//
//  Loggable.swift
//  Transitions
//
//  Created by Sebastian Wild on 7/12/22.
//  Copyright © 2022 Sebastian Wild. All rights reserved.
//

import Foundation
import os

protocol Loggable {
    var log: Logger { get }
    static var log: Logger { get }
}

extension Loggable {
    private static var subsystem: String { Bundle.main.bundleIdentifier ?? "dev.sebaswild.transitions" }
    // TODO: Are there any performance implications to re-creating these every time?
    var log: Logger {
        Logger(subsystem: Self.subsystem, category: String(describing: self))
    }

    static var log: Logger {
        Logger(subsystem: Self.subsystem, category: String(describing: self))
    }
}
