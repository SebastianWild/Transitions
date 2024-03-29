//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Combine
import Foundation

class InternalDisplay: Display, Loggable {
    let id: CGDirectDisplayID
    var name: String
    let isInternalDisplay = true
    private(set) var brightness: Float = 0.0 {
        didSet {
            readingSubject.send(.success(brightness))
        }
    }

    private(set) var error: BrightnessReadError? {
        didSet {
            guard let error = error else { return }
            readingSubject.send(.failure(error))
        }
    }

    private var readingSubject = CurrentValueSubject<BrightnessReading, Never>(.failure(.noDisplays(original: nil)))
    var reading: AnyPublisher<BrightnessReading, Never> {
        readingSubject.eraseToAnyPublisher()
    }

    private var brightnessUpdateCancellable: AnyCancellable?
    private lazy var plistdecoder = PropertyListDecoder()

    convenience init() throws {
        guard let nsScreen = NSScreen.internalDisplay else {
            InternalDisplay.log.warning("Could not create InternalDisplay - no internal display found")
            throw InternalDisplayError.notAvailable
        }
        try self.init(screen: nsScreen)
    }

    init(screen: NSScreen) throws {
        guard let id = screen.displayID else {
            InternalDisplay.log.warning("Could not create InternalDisplay - no display ID found")
            throw InternalDisplayError.noId
        }

        self.id = id
        name = screen.localizedName
        error = nil
        brightness = 0.0

        brightnessUpdateCancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .compactMap { [weak self] _ in
                self?.readBrightness()
            }
            .sink { [weak self] readingResult in
                switch readingResult {
                case let .success(brightness):
                    self?.log.debug("Got internal display brightness reading: \(brightness)")
                    self?.error = nil
                    self?.brightness = brightness
                case let .failure(error):
                    self?.log.error("Error when reading internal display brightness: \(error.localizedDescription)")
                    self?.log.info("Setting brightness to -1 due to error")
                    self?.error = error
                    self?.brightness = -1.0
                }
            }
    }

    func readBrightness() -> BrightnessReading {
        let launchPath = "/usr/libexec/corebrightnessdiag"
        let args = ["status-info"]

        do {
            let stdout: Data? = try Shell.run(launchPath: launchPath, args: args)
            log.debug("Got new internal display corebrightnessdiag reading")

            guard let plist = stdout, !plist.isEmpty else {
                log.error("stdout was nil or empty")
                return .failure(BrightnessReadError.readError(displayMetadata: metadata, original: nil))
            }

            let displayInfo = try plistdecoder.decode(CoreBrightnessDiag.StatusInfo.self, from: plist)

            guard let brightness = displayInfo.internalDisplay()?.DisplayServicesBrightness else {
                log.error(
                    """
                    Display info decoded successfully, but no DisplayServicesBrightness found: \(displayInfo.debugDescription)
                    """
                )
                return .failure(BrightnessReadError.readError(displayMetadata: metadata, original: nil))
            }

            self.brightness = brightness
            return .success(brightness)
        } catch {
            log.error("Error when reading internal display brightness: \(error.localizedDescription)")
            return .failure(BrightnessReadError.readError(displayMetadata: metadata, original: error))
        }
    }
}

extension InternalDisplay {
    enum InternalDisplayError: LocalizedError {
        /// The internal display is not available
        case notAvailable
        /// The internal display has no CGDirectDisplayID
        case noId
    }
}
