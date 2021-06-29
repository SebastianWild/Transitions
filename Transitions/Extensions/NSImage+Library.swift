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
        var image: NSImage?
        if #available(macOS 11.0, *) {
            let symbolConfig = NSImage.SymbolConfiguration(pointSize: .statusBarIconPointSize, weight: .bold)
            image = NSImage(systemSymbolName: "sun.min", accessibilityDescription: nil)?.withSymbolConfiguration(symbolConfig)
        } else {
            image = NSImage(named: "sun.min")
        }

        guard let statusBarIcon = image else {
            fatalError("Asset not found!")
        }

        statusBarIcon.isTemplate = true
        statusBarIcon.size = .statusBarIcon

        return statusBarIcon
    }
}
