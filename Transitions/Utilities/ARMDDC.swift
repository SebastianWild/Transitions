//
//  ARMDDC.swift
//  Transitions
//
//  Created by Sebastian Wild on 10/3/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation

class ARMDDC {
    let displayID: CGDirectDisplayID

    init?(for displayID: CGDirectDisplayID) {
        self.displayID = displayID
    }
}

extension ARMDDC: DDCControlling {
    func readBrightness() -> BrightnessReading {
        // TODO:
        .success(-1.0)
    }

    func readDisplayName() -> String {
        // TODO:
        "ARM DDC Display"
    }
}
