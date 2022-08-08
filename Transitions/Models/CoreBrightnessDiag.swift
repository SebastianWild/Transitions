//
// Created by Sebastian Wild on 8/10/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
enum CoreBrightnessDiag {
    struct StatusInfo: Codable {
        // note: most things are omitted
        let CBDisplays: [String: CBDisplay]
    }

    struct CBDisplay: Codable {
        let Display: Display
    }

    struct Display: Codable {
        let DisplayServicesBrightness: Float?
        let DisplayServicesIsBuiltInDisplay: Bool?
    }
}

extension CoreBrightnessDiag.StatusInfo: CustomDebugStringConvertible {
    public var debugDescription: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self)
        return String(data: data ?? Data(), encoding: .utf8) ?? "nil"
    }
}
