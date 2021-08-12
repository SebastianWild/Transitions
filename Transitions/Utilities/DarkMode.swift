//
// Created by Sebastian Wild on 8/11/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum DarkMode {
    static func set(on: Bool) throws {
        try (on ? NSAppleScript.setDarkModeOn : NSAppleScript.setDarkModeOff).execute()
    }

    static func get() throws -> Bool {
        try NSAppleScript.getDarkMode.execute().booleanValue
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
