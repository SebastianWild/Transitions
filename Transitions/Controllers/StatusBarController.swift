//
//  StatusItemController.swift
//  Transitions
//
//  Created by Sebastian Wild on 3/13/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa

final class StatusBarController: NSObject {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem

    override init() {
        statusBar = NSStatusBar()
        statusItem = statusBar.statusItem(withLength: 28.0)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(named: "sun.min")
            statusBarButton.image?.size = NSSize(width: 18, height: 18)
            // We want the image to change color with the system theme change as well
            statusBarButton.image?.isTemplate = true
        }
    }
}
