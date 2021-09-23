//
//  PreferencesPane.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/14/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation
import Preferences
import SwiftUI

// swiftlint:disable line_length
/*
 Here I rely heavily on Sidre Sorhus's great Preferences UI library, whose MIT license is pasted below and also visible in Transition's settings:

 MIT License

 Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (sindresorhus.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
// swiftlint:enable line_length

// MARK: - Preference Window Controller Builder

extension Preferences {
    static let contentWidth: Double = 450.0

    static func buildController(with userData: UserData = .main, and controller: DisplaysController = .main) -> PreferencesWindowController {
        PreferencesWindowController(
            panes: [
                Preferences.general(with: userData, and: controller),
                Preferences.about(with: userData, and: controller)
            ]
        )
    }
}

// MARK: - PreferencePaneConvertible Builders

extension Preferences {
    static func general(with userData: UserData = .main, and controller: DisplaysController = .main) -> PreferencePaneConvertible {
        Preferences.Pane(
            identifier: Preferences.PaneIdentifier("general"),
            title: "general".localized,
            toolbarIcon: .gear
        ) {
            Preferences.Container.General()
                .environmentObject(userData)
                .environmentObject(controller)
        }
    }

    static func about(with userData: UserData = .main, and controller: DisplaysController = .main) -> PreferencePaneConvertible {
        Preferences.Pane(
            identifier: Preferences.PaneIdentifier("about"),
            title: "about".localized,
            toolbarIcon: .info_circle
        ) {
            Preferences.Container.About()
                .environmentObject(userData)
                .environmentObject(controller)
        }
    }
}
