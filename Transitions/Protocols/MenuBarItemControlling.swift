//
// Created by Sebastian Wild on 9/24/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

/// `MenuBarItemControlling` will show/hide the menu bar item as needed
protocol MenuBarItemControlling {
    /// Callback invoked when the popover is shown (the user taps on it)
    var onPopOverShow: (() -> Void)? { get set }
    /// Callback invoked when the user taps on the preferences button in the popover
    var onPreferencesTap: (() -> Void)? { get set }

    /// Places the menu item in the macOS menu bar
    func showMenuItem()
    /// Remove the menu item from the macOS menu bar
    func removeMenuItem()
}
