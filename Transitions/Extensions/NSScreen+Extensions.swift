//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Cocoa

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
}
