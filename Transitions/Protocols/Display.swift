//
//  Display.swift
//  Transitions
//
//  Created by Sebastian Wild on 7/5/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

typealias BrightnessReading = Result<Float, BrightnessReadError>

protocol Display: ObservableObject {
    var name: String { get set }
    /// Brightness for a display is defined from 0.0 to 1.0
    var brightness: Float { get }
    var error: BrightnessReadError? { get }
    var isInternalDisplay: Bool { get }

    var metadata: DisplayMetadata { get }
}

class AnyDisplay {
    private let nameGetter: () -> String
    private let nameSetter: (String) -> Void
    private let brightnessGetter: () -> Float
    private let errorGetter: () -> BrightnessReadError?
    private let isInternalDisplayGetter: () -> Bool

    init<D: Display>(display: D) {
        nameGetter = { display.name }
        brightnessGetter = { display.brightness }
        errorGetter = { display.error }
        isInternalDisplayGetter = { display.isInternalDisplay }
        nameSetter = { display.name = $0 }
    }
}

extension AnyDisplay: Display {
    var name: String {
        get {
            nameGetter()
        }
        set {
            nameSetter(newValue)
        }
    }

    var brightness: Float {
        brightnessGetter()
    }

    var error: BrightnessReadError? {
        errorGetter()
    }

    var isInternalDisplay: Bool {
        isInternalDisplayGetter()
    }
}

extension Display {
    func eraseToAnyDisplay() -> AnyDisplay {
        AnyDisplay(display: self)
    }
}

extension Display {
    var metadata: DisplayMetadata {
        DisplayMetadata(name: name)
    }
}

struct DisplayMetadata {
    let name: String
}
