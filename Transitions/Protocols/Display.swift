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

protocol Display {
    var id: CGDirectDisplayID { get }
    var name: String { get set }
    /// Brightness for a display is defined from 0.0 to 1.0
    var brightness: Float { get }
    var error: BrightnessReadError? { get }
    var isInternalDisplay: Bool { get }

    var metadata: DisplayMetadata { get }

    var reading: AnyPublisher<BrightnessReading, Never> { get }
}

extension Display {
    var metadata: DisplayMetadata {
        DisplayMetadata(name: name)
        return DisplayMetadata(name: name, info: nil)
    }
}

struct DisplayMetadata {
    let name: String
    /// Additional info applicable to external (DDC) displays
    let info: Info?
}

struct Info {
    let yearOfManufacture: Int
    let weekOfManufacture: Int
    let vendorId: Int
    let productId: Int
    let horizontalImageSize: Int
    let verticalImageSize: Int
}
