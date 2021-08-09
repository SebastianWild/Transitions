//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum Preview {
    class MockDisplay: Display {
        @Published var name = "MockDisplay"
        @Published var brightness: Float
        @Published var error: BrightnessReadError?
        let isInternalDisplay: Bool

        init(reading: BrightnessReading = .success(0.5), isInternal: Bool = true) {
            isInternalDisplay = isInternal
            brightness = (try? reading.get()) ?? 0.0
            switch reading {
            case let .success(brightness):
                error = nil
                self.brightness = brightness
            case let .failure(error):
                self.error = error
                brightness = -1.0
            }
        }
    }
}
