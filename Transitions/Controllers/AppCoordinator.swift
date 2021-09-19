//
//  AppStartController.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/29/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Foundation
import SwiftUI

import Preferences

/**
 Class responsible for bootstrapping the app UI and navigating between views
 */
class AppCoordinator: NSObject {
    private var userData: UserData
    private var displaysController: DisplaysController

    /// Will be nil when the menu bar item is turned off
    private var statusBarController: StatusBarController?
    /// Will be nil when the menu bar item is turned off
    private var statusBarPopover: NSPopover?

    private var preferencesWindowController: PreferencesWindowController?

    init(
        userData: UserData = .main,
        displaysController: DisplaysController = .main
    ) {
        self.userData = userData
        self.displaysController = displaysController
    }

    /**
     To be called at app start to show the UI
     */
    func showUI() {
        // For now, we always show the menu item
        // In the future, user preferences will control what is shown
        createMenuItem()
    }
}

// MARK: - Menu Item handling

extension AppCoordinator {
    private func createMenuItem() {
        let popover = NSPopover()
        popover.contentSize = .popover

        statusBarController = StatusBarController(
            popover,
            onShow: { [weak self] in
                self?.displaysController.refresh()
            }
        )

        popover.contentViewController = NSHostingController(
            rootView: StatusBarPreferences { [weak self] in self?.showPreferencesUI() }
                .environmentObject(displaysController)
                .environmentObject(userData)
        )

        statusBarPopover = popover
    }
}

// MARK: - Preferences UI handling

extension AppCoordinator: NSWindowDelegate {
    private func showPreferencesUI() {
        guard preferencesWindowController == nil else {
            preferencesWindowController?.showWindow(self)
            return
        }

        preferencesWindowController = PreferencePanes.buildController(with: userData, and: displaysController)
        preferencesWindowController?.window?.delegate = self
        preferencesWindowController?.show()
    }

    public func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == preferencesWindowController {
            preferencesWindowController = nil
        }
    }
}
