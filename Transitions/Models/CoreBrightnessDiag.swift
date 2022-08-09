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
    struct StatusInfo: Decodable, InternalDisplayBrightnessReadable, CustomDebugStringConvertible {
        // note: most things are omitted
        let CBDisplays: [String: InternalDisplayBrightnessReadable]

        var DisplayServicesBrightness: Float? {
            CBDisplays.first?.value.DisplayServicesBrightness
        }

        var DisplayServicesIsBuiltInDisplay: Bool? {
            CBDisplays.first?.value.DisplayServicesIsBuiltInDisplay
        }

        var debugDescription: String {
            let brightness = DisplayServicesBrightness != nil ? "\(DisplayServicesBrightness!)" : "nil"
            let isInternal = DisplayServicesIsBuiltInDisplay != nil ? "\(DisplayServicesIsBuiltInDisplay!)" : "nil"

            return
                """
                DisplayServicesBrightness: \(brightness)
                DisplayServicesIsBuiltInDisplay: \(isInternal)
                """
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let cbDisplays = try? container.decode([String: CBDisplay].self, forKey: .CBDisplays) as [String: InternalDisplayBrightnessReadable] {
                CBDisplays = cbDisplays
            } else if let displays = try? container.decode([String: Display].self, forKey: .CBDisplays) as [String: InternalDisplayBrightnessReadable] {
                CBDisplays = displays
            } else {
                throw DecodingError.typeMismatch(
                    StatusInfo.self,
                    .init(codingPath: [CodingKeys.CBDisplays], debugDescription: "Could not decode CBDisplay or Display")
                )
            }
        }

        enum CodingKeys: String, CodingKey {
            case CBDisplays
        }
    }

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
