//
//  AppStartController.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/29/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Combine
import Foundation
import SwiftUI

import Preferences

/**
 Class responsible for bootstrapping the app UI and navigating between views
 */
class AppCoordinator: NSObject {
    private var userData: UserData
    private var displaysController: DisplaysController

    private var statusBarController: MenuBarItemControlling

    private var preferencesWindowController: PreferencesWindowController?

    init(
        userData: UserData = .main,
        displaysController: DisplaysController = .main,
        statusBarController: MenuBarItemControlling = MenuBarBarController()
    ) {
        self.userData = userData
        self.displaysController = displaysController

        self.statusBarController = statusBarController

        super.init()

        self.statusBarController.onPreferencesTap = { [weak self] in
            self?.showPreferencesUI()
        }
        self.statusBarController.onPopOverShow = { [weak self] in
            self?.displaysController.refresh()
        }
    }

    /**
     To be called at app start to show the UI
     */
    func showUI() {
        if userData.isMenuletEnabled {
            statusBarController.showMenuItem()
        }
    }
}

// MARK: - Preferences UI handling

extension AppCoordinator: NSWindowDelegate {
    private func showPreferencesUI() {
        guard preferencesWindowController == nil else {
            preferencesWindowController?.showWindow(self)
            return
        }

        preferencesWindowController = Preferences.buildController(with: userData, and: displaysController)
        preferencesWindowController?.window?.delegate = self
        preferencesWindowController?.show()
    }

    public func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == preferencesWindowController {
            preferencesWindowController = nil
        }
    }
}
