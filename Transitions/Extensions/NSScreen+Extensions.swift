//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import DDC

extension NSScreen {
    static var internalDisplay: NSScreen? {
        // Pretty sure there is no mac with two internal displays?
        screens.first(where: { $0.isInternalDisplay })
    }

    var isInternalDisplay: Bool {
        let description = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")

        guard let deviceID = deviceDescription[description] as? NSNumber else { return false }

        return CGDisplayIsBuiltin(deviceID.uint32Value) != 0
    }

    var displayID: CGDirectDisplayID? {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }
}

extension NSScreen {
    func ddc() -> DDCControlling? {
        guard let id = displayID else {
            return nil
        }

        #if arch(arm64)
            return ARMDDC(for: id)
        #else
            return DDC(for: id)
        #endif
    }
}
