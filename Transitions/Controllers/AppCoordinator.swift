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

    private var menuBarController: MenuBarItemControlling
    private let appPreferenceWindowController: AppPreferenceWindowControlling

    private var bag = Set<AnyCancellable>()

    init(
        userData: UserData = .main,
        displaysController: DisplaysController = .main,
        menuBarController: MenuBarItemControlling = MenuBarBarController(),
        appPreferenceWindowController: AppPreferenceWindowControlling = AppPreferenceWindowController()
    ) {
        self.userData = userData
        self.displaysController = displaysController
        self.menuBarController = menuBarController
        self.appPreferenceWindowController = appPreferenceWindowController

        super.init()

        self.menuBarController.onPreferencesTap = { [weak self] in
            self?.appPreferenceWindowController.showPreferencesWindow()
        }
        self.menuBarController.onPopOverShow = { [weak self] in
            self?.displaysController.refresh()
        }

        userData.$isMenuletEnabled
            // Upon subscribing, the current value will publish
            // we don't need to react on this as `showUI` will handle the first showing
            .dropFirst()
            .sink { [weak self] enabled in
                enabled ? self?.menuBarController.showMenuItem() : self?.menuBarController.removeMenuItem()
            }.store(in: &bag)
    }

    // MARK: - Public API

    /**
     To be called at app start to show the UI
     */
    func showUI() {
        if userData.isMenuletEnabled {
            menuBarController.showMenuItem()
        }
    }
}
