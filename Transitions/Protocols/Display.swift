//
//  Display.swift
//  Transitions
//
//  Created by Sebastian Wild on 7/5/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation
import Combine

protocol Display: Identifiable {
    var name: String { get set }
    /// Brightness for a display is defined from 0.0 to 1.0
    var brightness: Float { get }
    var brightnessChangePublisher: AnyPublisher<Float, Never> { get }
}
