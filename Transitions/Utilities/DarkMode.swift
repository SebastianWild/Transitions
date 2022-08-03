//
// Created by Sebastian Wild on 8/11/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

protocol DarkModeControlling {
    static func set(on: Bool) throws
    static func get() throws -> Bool
}

enum DarkMode: DarkModeControlling, Loggable {
    static func set(on: Bool) throws {
        do {
            try (on ? NSAppleScript.setDarkModeOn : NSAppleScript.setDarkModeOff).execute()
        } catch {
            log.critical("Could not set dark mode to \(on), error: \(error.localizedDescription)")
            throw error
        }
    }

    static func get() throws -> Bool {
        do {
            return try NSAppleScript.getDarkMode.execute().booleanValue
        } catch {
            log.critical("Could not get dark mode: \(error.localizedDescription)")
            throw error
        }
    }
}

extension NSAppleScript {
    @discardableResult
    func execute() throws -> NSAppleEventDescriptor {
        var errorInfo: NSDictionary?

        let eventDescriptor = executeAndReturnError(&errorInfo)

        if errorInfo != nil {
            throw AppleScriptError.execution(errorInfo: errorInfo)
        }

        return eventDescriptor
    }

    static var setDarkModeOn: NSAppleScript {
        guard let script = NSAppleScript(source: scriptSource(forDarkMode: true)) else {
            fatalError("Could not create NSAppleScript from hardcoded source!")
        }

        return script
    }

    static var setDarkModeOff: NSAppleScript {
        guard let script = NSAppleScript(source: scriptSource(forDarkMode: false)) else {
            fatalError("Could not create NSAppleScript from hardcoded source!")
        }

        return script
    }

    static var getDarkMode: NSAppleScript {
        guard let script = NSAppleScript(source: scriptSourceGetDarkMode) else {
            fatalError("Could not create NSAppleScript from hardcoded source!")
        }

        return script
    }

    private static func scriptSource(forDarkMode on: Bool) -> String {
        """
        tell application "System Events"
            tell appearance preferences 
                set dark mode to \(on) 
            end tell
        end tell
        """
    }

    private static let scriptSourceGetDarkMode: String =
        """
        tell application "System Events"
            return dark mode of appearance preferences
        end tell
        """

    enum AppleScriptError: LocalizedError {
        case execution(errorInfo: NSDictionary?)
    }
}
