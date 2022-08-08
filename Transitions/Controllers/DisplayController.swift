//
// Created by Sebastian Wild on 8/11/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation

/// `DisplayController` listens to brightness changes on a display and triggers toggling of the system dark mode
/// when appropriate
class DisplayController<Controller: DarkModeControlling>: Loggable {
    private let display: Display
    private let threshold: Float
    private let controller: DarkModeControlling.Type

    private var oldBrightness: Float

    private var brightnessChangeCancellable: AnyCancellable?

    init(display: Display, threshold: Float, controller: Controller.Type) {
        self.display = display
        self.threshold = threshold
        self.controller = controller
        oldBrightness = display.brightness

        setUpListener()
    }

    private func setUpListener() {
        brightnessChangeCancellable = display.reading
            .compactMap {
                try? $0.get()
            }
            // The brightness change publisher never fails, so negative display brightnesses are considered errors
            .filter { $0 > 0 }
            .compactMap { brightness -> (Bool, Float)? in
                guard let isDarkModeEnabled = try? DarkMode.get() else { return nil }

                return (isDarkModeEnabled, brightness)
            }
            // TODO: Error handling!, bubble this up to user?
            .sink { [threshold] (isDarkModeEnabled: Bool, brightness: Float) in
                if brightness > threshold, isDarkModeEnabled {
                    try? Controller.set(on: false)
                } else if brightness < threshold, !isDarkModeEnabled {
                    try? Controller.set(on: true)
                }
            }
    }
}
