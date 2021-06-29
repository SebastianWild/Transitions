//
//  StatusItemController.swift
//  Transitions
//
//  Created by Sebastian Wild on 3/13/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Combine

final class StatusBarController: NSObject {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private weak var popover: NSPopover?
    private var eventSubscriber: AnyCancellable?

    init(_ popover: NSPopover) {
        statusBar = NSStatusBar()
        statusItem = statusBar.statusItem(withLength: 28.0)
        statusItem.button?.image = .statusBarIcon

        self.popover = popover

        super.init()

        statusItem.button?.action = #selector(togglePopOver(sender:))
        statusItem.button?.target = self

        eventSubscriber = Publishers.Merge(
            NSEvent.publisher(for: .leftMouseDown),
            NSEvent.publisher(for: .rightMouseDown)
        )
        .sink { [weak self] _ in
            guard let self = self else { return }
            self.hidePopOver(self)
        }
    }

    @objc
    func togglePopOver(sender: AnyObject) {
        popover?.isShown ?? false ? hidePopOver(sender) : showPopover()
    }

    private func hidePopOver(_ sender: AnyObject) {
        popover?.performClose(sender)
    }

    private func showPopover() {
        if let button = statusItem.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
    }
}
