//
// Created by Sebastian Wild on 8/11/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation

/// `DarkModeController` listens to brightness changes on a display and triggers toggling of the system dark mode
/// when appropriate
class DarkModeController {
    private let display: Display
    private let threshold: Float

    private var oldBrightness: Float

    private var brightnessChangeCancellable: AnyCancellable?

    init(display: Display, threshold: Float) {
        self.display = display
        self.threshold = threshold
        oldBrightness = display.brightness

        setUpListener()
    }

    private func setUpListener() {
        brightnessChangeCancellable = display.reading
            .compactMap {
                try? $0.get()
            }
            .compactMap { brightness -> (Bool, Float)? in
                guard let isDarkModeEnabled = try? DarkMode.get() else { return nil }

                return (isDarkModeEnabled, brightness)
            }
            // TODO: Error handling!, bubble this up to user?
            .sink { [threshold] (isDarkModeEnabled: Bool, brightness: Float) in
                if brightness > threshold, isDarkModeEnabled {
                    try? DarkMode.set(on: false)
                } else if brightness < threshold, !isDarkModeEnabled {
                    try? DarkMode.set(on: true)
                }
            }
    }
}
