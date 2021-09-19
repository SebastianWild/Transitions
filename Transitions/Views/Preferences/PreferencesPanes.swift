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

enum PreferencePanes {
    static let contentWidth: Double = 450.0

    static func buildController(with userData: UserData = .main, and controller: DisplaysController = .main) -> PreferencesWindowController {
        PreferencesWindowController(
            panes: [
                Preferences.Pane(
                    identifier: Preferences.PaneIdentifier("general"),
                    title: "general".localized,
                    toolbarIcon: .gear
                ) {
                    General()
                        .environmentObject(userData)
                        .environmentObject(controller)
                },
                Preferences.Pane(
                    identifier: Preferences.PaneIdentifier("about"),
                    title: "about".localized,
                    toolbarIcon: .info_circle
                ) {
                    About()
                        .environmentObject(userData)
                        .environmentObject(controller)
                }
            ]
        )
    }
}

extension PreferencePanes {
    struct General: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        var body: some View {
            Preferences.Container(contentWidth: PreferencePanes.contentWidth) {
                Preferences.Section(title: "general".localized) {
                    Text(LocalizedStringKey.Preferences.general)
                        .font(.headline)
                    Toggle(isOn: $userData.isAppEnabled) {
                        Text(LocalizedStringKey.Preferences.enabled)
                    }
                    Toggle(isOn: $controller.isStartingOnLogon) {
                        Text(LocalizedStringKey.Preferences.start_on_logon)
                    }
                }
            }
        }
    }
}

extension PreferencePanes {
    struct About: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        var body: some View {
            Preferences.Container(contentWidth: PreferencePanes.contentWidth) {
                Preferences.Section(title: "About") {
                    Text("About")
                }
            }
        }
    }
}

struct PreferencePanes_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferencePanes.General()
                .environmentObject(UserData())
                .environmentObject(DisplaysController(userData: UserData()))
                .previewDisplayName("General")
            PreferencePanes.About()
                .environmentObject(UserData())
                .environmentObject(DisplaysController(userData: UserData()))
                .previewDisplayName("About")
        }
    }
}
