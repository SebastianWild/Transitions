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
    lazy var coordinator = AppCoordinator()

    func applicationDidFinishLaunching(_: Notification) {
        coordinator.showUI()
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
