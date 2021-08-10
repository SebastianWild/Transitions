//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation

enum Preview {
    class MockDisplay: Display {
        var name = "MockDisplay"
        let isInternalDisplay: Bool
        var brightness: Float = 0.0 {
            didSet {
                readingSubject.send(.success(brightness))
            }
        }

        var error: BrightnessReadError? {
            didSet {
                guard let error = error else { return }
                readingSubject.send(.failure(error))
            }
        }

        private var readingSubject = CurrentValueSubject<BrightnessReading, Never>(.failure(.noDisplays(original: nil)))
        var reading: AnyPublisher<BrightnessReading, Never> {
            readingSubject.eraseToAnyPublisher()
        }

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
