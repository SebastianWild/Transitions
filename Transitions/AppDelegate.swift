//
//  AppDelegate.swift
//  Transitions
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarController?
    lazy var popover = NSPopover()

    @CodableUserDefaultProperty(UserDefaults.Keys.userData, defaultValue: UserData())
    private var userData: UserData
    private let displayManager = DisplayManager()

    func applicationDidFinishLaunching(_: Notification) {
        let contentView = PreferencesView()
            .environmentObject(userData)
            .environmentObject(displayManager)

        popover.contentSize = .popover
        popover.contentViewController = NSHostingController(rootView: contentView)

        statusBar = StatusBarController(popover)
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
