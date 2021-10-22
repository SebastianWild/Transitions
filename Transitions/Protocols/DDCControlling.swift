//
//  DDCControlling.swift
//  Transitions
//
//  Created by Sebastian Wild on 10/3/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import AppKit
import Foundation

protocol DDCControlling {
    func readBrightness() -> BrightnessReading
}
