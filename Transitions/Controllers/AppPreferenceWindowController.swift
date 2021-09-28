//
// Created by Sebastian Wild on 9/24/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Foundation
import Preferences

class AppPreferenceWindowController: NSObject, AppPreferenceWindowControlling, NSWindowDelegate {
    private var preferencesWindowController: PreferencesWindowController?

    private let userData: UserData
    private let displaysController: DisplaysController

    init(userData: UserData = .main, displaysController: DisplaysController = .main) {
        self.userData = userData
        self.displaysController = displaysController
        super.init()
    }

    func showPreferencesWindow() {
        guard preferencesWindowController == nil else {
            preferencesWindowController?.showWindow(self)
            // If the user already has the preference window open, another application could be covering it -
            // we should make the preference window come to the front regardless of what window is currently in front.
            preferencesWindowController?.window?.orderFrontRegardless()
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
