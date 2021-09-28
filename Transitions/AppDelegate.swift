//
//  AppDelegate.swift
//  Transitions
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Cocoa
import Combine
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var coordinator: AppCoordinating = AppCoordinator()

    func applicationDidFinishLaunching(_: Notification) {
        coordinator.applicationDidFinishLaunching()
    }

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        coordinator.applicationShouldHandleReopen()
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
