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

    @CodableUserDefaultProperty(UserDefaults.Keys.userData, defaultValue: UserData())
    private var userData: UserData

    func applicationDidFinishLaunching(_: Notification) {
        statusBar = StatusBarController()
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
