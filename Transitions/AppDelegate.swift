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
    private let displayManager = DisplayManager()
    private var darkModeController: DarkModeController?

    private var primaryDisplayUpdateCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_: Notification) {
        let contentView = PreferencesView()
            .environmentObject(userData)
            .environmentObject(displayManager)

        popover.contentSize = .popover
        popover.contentViewController = NSHostingController(rootView: contentView)

        statusBar = StatusBarController(popover)

        let primaryDisplayChangedHandler = displayManager.$displays
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .map(\.first) // The first display is the primary display
            .handleEvents(receiveOutput: { [weak self] display in
                if display == nil {
                    self?.darkModeController = nil
                }
            })
            .compactMap { $0 } // If there is no primary display, we cannot continue

        // Configure re-creating the DarkModeController when user preferences or displays change
        primaryDisplayUpdateCancellable = Publishers.CombineLatest(primaryDisplayChangedHandler, userData.$interfaceStyleSwitchTriggerValue)
            .map { display, thresholdValue in
                DarkModeController(display: display, threshold: thresholdValue)
            }
            .sink { [weak self] controller in
                self?.darkModeController = controller
            }
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
