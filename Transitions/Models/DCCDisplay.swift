//
//  DCCDisplay.swift
//  Transitions
//
//  Created by Sebastian Wild on 10/3/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import AppKit
import Combine
import DDC
import Foundation

class DDCDisplay {
    let id: CGDirectDisplayID
    private let ddc: DDCControlling
    @Published private var _reading: BrightnessReading = .failure(.notPerformed)
    private var updateCancellable: AnyCancellable?

    init?(_ screen: NSScreen) {
        guard
            let ddc = screen.ddc(),
            let id = screen.displayID
        else {
            return nil
        }

        self.id = id
        self.ddc = ddc
        updateCancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.global(qos: .background))
            .asyncMap { [ddc] _ in
                await ddc.readBrightness()
            }
            .handleEvents(receiveOutput: { reading in
                print("Received new external display reading: \(reading)")
            })
            .receive(on: DispatchQueue.main)
            .assignWeakly(to: \._reading, on: self)
    }
}

extension DDCDisplay: Display {
    var name: String {
        get {
            metadata.info?.displayProductName ?? "External Display \(id)"
        }
        set {
            // For now, it is not possible to set the name
        }
    }

    var brightness: Float {
        if case let .success(brightness) = _reading {
            return brightness
        } else {
            return 0.0
        }
    }

    var error: BrightnessReadError? {
        if case let .failure(error) = _reading {
            return error
        } else {
            return nil
        }
    }

    var isInternalDisplay: Bool {
        false
    }

    var reading: AnyPublisher<BrightnessReading, Never> {
        $_reading.eraseToAnyPublisher()
    }
}
