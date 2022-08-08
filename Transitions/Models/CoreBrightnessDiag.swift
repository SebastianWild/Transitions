//
// Created by Sebastian Wild on 8/10/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

protocol InternalDisplayBrightnessReadable: Decodable {
    // swiftlint:disable identifier_name
    var DisplayServicesBrightness: Float? { get }
    // swiftlint:disable identifier_name
    var DisplayServicesIsBuiltInDisplay: Bool? { get }
}

// swiftlint:disable identifier_name
enum CoreBrightnessDiag {
    struct StatusInfo: Decodable, InternalDisplayBrightnessReadable {
        // note: most things are omitted
        let CBDisplays: [String: InternalDisplayBrightnessReadable]

        var DisplayServicesBrightness: Float? {
            CBDisplays.first?.value.DisplayServicesBrightness
        }

        var DisplayServicesIsBuiltInDisplay: Bool? {
            CBDisplays.first?.value.DisplayServicesIsBuiltInDisplay
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let cbDisplays = try? container.decode([String: CBDisplay].self, forKey: .CBDisplays) as [String: InternalDisplayBrightnessReadable] {
                CBDisplays = cbDisplays
            } else if let displays = try? container.decode([String: Display].self, forKey: .CBDisplays) as [String: InternalDisplayBrightnessReadable] {
                CBDisplays = displays
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected CBDisplays or CBDisplays.CBDisplay"
                )
            }
        }
    }

//    struct MinimalStatusInfo: Codable, InternalDisplayBrightnessReadable {
//        let CBDisplays: [String: Display]
//
//        var DisplayServicesBrightness: Float? {
//            CBDisplays.first?.value.Display.DisplayServicesBrightness
//        }
//
//        var DisplayServicesIsBuiltInDisplay: Bool? {
//            CBDisplays.first?.value.Display.DisplayServicesIsBuiltInDisplay
//        }
//    }

    struct CBDisplay: Decodable, InternalDisplayBrightnessReadable {
        let Display: Display

        var DisplayServicesBrightness: Float? {
            Display.DisplayServicesBrightness
        }

        var DisplayServicesIsBuiltInDisplay: Bool? {
            Display.DisplayServicesIsBuiltInDisplay
        }
    }

    struct Display: Decodable, InternalDisplayBrightnessReadable {
        let DisplayServicesBrightness: Float?
        let DisplayServicesIsBuiltInDisplay: Bool?
    }
}
