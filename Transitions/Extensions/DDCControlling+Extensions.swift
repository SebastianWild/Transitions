//
//  DDCControlling+Extensions.swift
//  Transitions
//
//  Created by Sebastian Wild on 10/3/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import AppKit
import DDC
import Foundation

extension DDC: DDCControlling {
    func readBrightness() async -> BrightnessReading {
        guard let (current, max) = read(command: .brightness) else {
            return .failure(.readError(displayMetadata: nil, original: nil))
        }

        guard max != 0 else {
            return .failure(.readError(displayMetadata: nil, original: nil))
        }

        return .success(Float(current) / Float(max))
    }

    func readDisplayName() -> String {
        // TODO: Check this
        edid()?.manufacturerString() ?? "N/A"
    }
}
