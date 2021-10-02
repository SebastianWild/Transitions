//
// Created by Sebastian Wild on 9/24/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Foundation
import Preferences

class AppPreferenceWindowController: NSObject, AppPreferenceWindowControlling, NSWindowDelegate {
    typealias SetActivationPolicy = (NSApplication.ActivationPolicy) -> Bool

    private var preferencesWindowController: PreferencesWindowController?

    private let userData: UserData
    private let displaysController: DisplaysController
    private let setActivationPolicy: SetActivationPolicy

    init(
        userData: UserData = .main,
        displaysController: DisplaysController = .main,
        activationPolicySetting: @escaping SetActivationPolicy = NSApp.setActivationPolicy(_:)
    ) {
        self.userData = userData
        self.displaysController = displaysController
        setActivationPolicy = activationPolicySetting
        super.init()
    }

    func showPreferencesWindow() {
        _ = setActivationPolicy(.regular)

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
        _ = setActivationPolicy(.prohibited)

        if let window = notification.object as? NSWindow, window == preferencesWindowController {
            preferencesWindowController = nil
        }
    }
}
