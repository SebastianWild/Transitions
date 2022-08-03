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

extension DDC: DDCControlling, Loggable {
    func readBrightness() async -> BrightnessReading {
        guard let (current, max) = read(command: .brightness) else {
            log.error("Failed to read brightness from Intel-DDC implementation! Error unknown.")
            return .failure(.readError(displayMetadata: nil, original: nil))
        }

        guard max != 0 else {
            log.error("Got < 0 max brightness from Intel-DDC.")
            return .failure(.readError(displayMetadata: nil, original: nil))
        }

        return .success(Float(current) / Float(max))
    }

    func readDisplayName() -> String {
        // TODO: Check this
        edid()?.manufacturerString() ?? "N/A"
    }
}
