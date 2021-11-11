//
//  ARMDDC.swift
//  Transitions
//
//  Created by Sebastian Wild on 10/3/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation

/*
 DDC reading steps (ARM)
    1. Get a reference to the IOAVService
    2. Send I2C command:
        a.
 */

class ARMDDC {

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
