//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Combine
import Foundation

class InternalDisplay: Display {
    @Published var name: String
    let isInternalDisplay = true
    @Published private(set) var brightness: Float = 0.0
    @Published private(set) var error: BrightnessReadError?

    private var brightnessUpdateCancellable: AnyCancellable?

    init(screen: NSScreen) {
        name = screen.localizedName
        error = nil
        brightness = 0.0

        brightnessUpdateCancellable = Timer.publish(every: 1, on: .main, in: .default)
            .compactMap { [weak self] _ in
                self?.readBrightness()
            }
            .sink { [weak self] readingResult in
                switch readingResult {
                case let .success(brightness):
                    self?.error = nil
                    self?.brightness = brightness
                case let .failure(error):
                    self?.error = error
                    self?.brightness = -1.0
                }
            }
    }

    func readBrightness() -> BrightnessReading {
        let args = [
            "/usr/libexec/corebrightnessdiag",
            "status-info",
            "|",
            "grep 'DisplayServicesBrightness'"
        ]

        do {
            let stdout: String? = try Shell.run(args: args)

            guard
                let returnString = stdout,
                let range = stdout?.range(of: #".*"#, options: .regularExpression)
            else {
                return .failure(BrightnessReadError.readError(displayMetadata: metadata, original: nil))
            }

            let floatString = returnString[range.lowerBound ... range.upperBound]

            guard let brightness = Float(floatString) else {
                return .failure(BrightnessReadError.readError(displayMetadata: metadata, original: nil))
            }
            self.brightness = brightness
            return .success(brightness)
        } catch {
            return .failure(BrightnessReadError.readError(displayMetadata: metadata, original: error))
        }
    }
}
