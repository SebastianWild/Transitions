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

        statusItem.button?.image = .statusBarIcon
    }
}
