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
    private var popover: NSPopover

    init(_ popover: NSPopover) {
        statusBar = NSStatusBar()
        statusItem = statusBar.statusItem(withLength: 28.0)
        statusItem.button?.image = .statusBarIcon

        self.popover = popover

        super.init()

        statusItem.button?.action = #selector(togglePopOver(sender:))
        statusItem.button?.target = self
    }

    @objc func togglePopOver(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
    }
}
