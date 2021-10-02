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

    static var appIcon: some View {
        // Simply doing `Image("AppIcon)` does not work, see
        // https://stackoverflow.com/questions/62063972/how-do-i-include-ios-app-icon-image-within-the-app-itself/62064533#62064533
        Image(nsImage: NSImage.appIcon)
            .resizable()
            .scaledToFit()
    }
}

extension NSImage {
    static var statusBarIcon: NSImage {
        guard let icon = NSImage(named: "menubar") else {
            fatalError("Image not found in asset catalog!")
        }

        icon.isTemplate = true
        icon.size = .statusBarIcon

        return icon
    }

    static var gear: NSImage {
        guard let icon = NSImage(named: "gear") else {
            fatalError("Image not found in asset catalog!")
        }

        icon.isTemplate = true

        return icon
    }

    static var info_circle: NSImage {
        guard let icon = NSImage(named: "info.circle") else {
            fatalError("Image not found in asset catalog!")
        }

        icon.isTemplate = true

        return icon
    }

    static var appIcon: NSImage {
        guard let icon = NSImage(named: "AppIcon") else {
            fatalError("Image not found in asset catalog!")
        }

        return icon
    }
}
