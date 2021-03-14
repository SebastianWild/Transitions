//
//  NSImage+Library.swift
//  Transitions
//
//  Created by Sebastian Wild on 3/13/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa

extension NSImage {
    static var statusBarIcon: NSImage {
        guard let image = NSImage(named: "sun.min") else {
            fatalError("Asset not found!")
        }

        image.isTemplate = true
        image.size = NSSize(width: 18, height: 18)

        return image
    }
}
