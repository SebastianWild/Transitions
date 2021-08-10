//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

/// Helper functions to run commands in using /bin/sh in a separate process, and return their standard output
///
/// - attention: Does not work when the app this code runs is sandboxed
enum Shell {
    @discardableResult
    static func run(launchPath: String = "/bin/sh", args: [String]) throws -> String? {
        String(data: try run(launchPath: launchPath, args: args), encoding: .utf8)
    }

    @discardableResult
    static func run(launchPath: String = "/bin/sh", args: [String]) throws -> Data {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = launchPath
        process.arguments = args
        process.standardOutput = pipe
        let handle = pipe.fileHandleForReading
        process.launch()

        return handle.readDataToEndOfFile()
    }
}
