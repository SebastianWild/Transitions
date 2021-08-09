//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum Shell {
    @discardableResult
    static func run(args: [String]) throws -> String? {
        String(data: try run(args: args), encoding: .utf8)
    }

    @discardableResult
    static func run(args: [String]) throws -> Data {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = args
        process.standardOutput = pipe
        let handle = pipe.fileHandleForReading
        process.launch()

        return handle.readDataToEndOfFile()
    }
}
