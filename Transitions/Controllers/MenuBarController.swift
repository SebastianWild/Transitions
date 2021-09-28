//
//  StatusItemController.swift
//  Transitions
//
//  Created by Sebastian Wild on 3/13/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Combine
import SwiftUI

final class MenuBarBarController: NSObject, MenuBarItemControlling {
    var onPopOverShow: (() -> Void)?
    var onPreferencesTap: (() -> Void)?

    private let statusBar = NSStatusBar.system
    private var statusItem: NSStatusItem?
    private lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentSize = .popover
        popover.contentViewController = NSHostingController(
            rootView: MenuBarPreferences { [weak self] in
                guard let self = self else { return }
                self.onPreferencesTap?()
                self.hidePopOver(self)
            }
            .environmentObject(displaysController)
            .environmentObject(userData)
        )
        return popover
    }()

    private let userData: UserData
    private let displaysController: DisplaysController
    private var eventSubscriber: AnyCancellable?

    init(userData: UserData = .main, displaysController: DisplaysController = .main) {
        self.userData = userData
        self.displaysController = displaysController

        super.init()
    }

    // MARK: - MenuBarItemControlling

    func showMenuItem() {
        // Create the menu bar item.
        // This automatically adds it to the menu bar.
        statusItem = statusBar.statusItem(withLength: 28.0)
        statusItem?.button?.image = .statusBarIcon
        statusItem?.button?.action = #selector(togglePopOver(sender:))
        statusItem?.button?.target = self

        // We need to close the popover when the user taps outside of it
        eventSubscriber = Publishers.Merge(
            NSEvent.publisher(for: .leftMouseDown),
            NSEvent.publisher(for: .rightMouseDown)
        )
        .sink { [weak self] _ in
            guard let self = self else { return }
            self.hidePopOver(self)
        }
    }

    func removeMenuItem() {
        guard let item = statusItem else { return }

        statusBar.removeStatusItem(item)
    }

    // MARK: - Popover Handling

    @objc
    private func togglePopOver(sender: AnyObject) {
        popover.isShown ? hidePopOver(sender) : showPopover()
    }

    private func hidePopOver(_ sender: AnyObject) {
        popover.performClose(sender)
    }

    private func showPopover() {
        onPopOverShow?()

        if let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
    }
}
