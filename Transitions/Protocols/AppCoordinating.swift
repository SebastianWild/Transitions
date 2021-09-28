//
// Created by Sebastian Wild on 9/28/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

protocol AppCoordinating {
    init(
        userData: UserData,
        displaysController: DisplaysController,
        menuBarController: MenuBarItemControlling,
        appPreferenceWindowController: AppPreferenceWindowControlling
    )

    func applicationDidFinishLaunching()
    func applicationShouldHandleReopen() -> Bool
}
