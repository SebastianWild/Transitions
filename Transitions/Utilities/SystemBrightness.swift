//
//  SystemBrightness.swift
//  Transitions
//
//  Created by Sebastian Wild on 7/3/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa

enum SystemBrightness {
    /// - attention:  Does not work for Apple Silicon systems
    static func getBrightness() -> Float {
        var iterator: io_iterator_t = 0
        var brightness: Float = 0.0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"), &iterator) == kIOReturnSuccess {
            var service: io_object_t = 1
            while service != 0 {
                service = IOIteratorNext(iterator)
                IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
                IOObjectRelease(service)

                return brightness
            }
        }

        return brightness
    }
}
