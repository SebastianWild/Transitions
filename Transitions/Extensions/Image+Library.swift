//
//  Image+Library.swift
//  Transitions
//
//  Created by Sebastian Wild on 3/13/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import SwiftUI

extension Image {
    static var sun_max: some View {
        Image("sun.max")
            .resizable()
            .scaledToFit()
    }

    static var sun_min: some View {
        Image("sun.min")
            .resizable()
            .scaledToFit()
    }
}

extension NSImage {
    static var statusBarIcon: NSImage {
        guard let icon = NSImage(named: "sun.min") else {
            fatalError("Image not found in asset catalog!")
        }

        icon.isTemplate = true
        icon.size = .statusBarIcon

        return icon
    }
}
