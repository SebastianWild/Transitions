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
    var statusBar: StatusBarController?
    lazy var popover = NSPopover()

    private var userData: UserData = UserDefaults.standard.get(
        from: UserDefaults.Keys.userData.rawValue
    ) ?? UserData()
    private lazy var controller = TransitionsController(userData: userData)

    func applicationDidFinishLaunching(_: Notification) {
        // MARK: - Controller creation

        controller = TransitionsController(userData: userData)

        // MARK: - UI Creation

        let contentView = PreferencesView()
            .environmentObject(controller)
            .environmentObject(userData)

        popover.contentSize = .popover
        popover.contentViewController = NSHostingController(rootView: contentView)

        statusBar = StatusBarController(popover, onShow: { [weak self] in self?.controller.refresh() })
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
