//
// Created by Sebastian Wild on 8/13/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation
import LaunchAtLogin

enum LoginItem: Loggable {
    /**
     Adds or removed the login item for Transitions.app.

     pass `true` to enable.
     */
    static var enabled: Bool {
        get {
            LaunchAtLogin.isEnabled
        }
        set {
            log.info("Setting login item to \(newValue)")
            LaunchAtLogin.isEnabled = newValue
        }
    }
}
