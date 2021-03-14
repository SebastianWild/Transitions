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
    var window: NSWindow!
    var statusBar: StatusBarController?

    @CodableUserDefaultProperty(UserDefaults.Keys.userData, defaultValue: UserData())
    private var userData: UserData

    func applicationDidFinishLaunching(_: Notification) {
        let contentView = PreferencesView().environmentObject(userData)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)

        statusBar = StatusBarController()
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
