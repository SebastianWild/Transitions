//
// Created by Sebastian Wild on 8/10/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

extension CoreBrightnessDiag.StatusInfo {
    /// Attempts to find the CoreBrightnessDiag status-info output for the internal display
    func internalDisplay() -> InternalDisplayBrightnessReadable? {
        CBDisplays.first { _, CBDisplay in
            CBDisplay.DisplayServicesIsBuiltInDisplay ?? false
        }.map(\.1)
    }
}
