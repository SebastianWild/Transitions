//
//  General.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/23/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Preferences
import SwiftUI

extension Preferences.Section.General {
    /// The "General" preference section.
    ///
    /// - Important: all views require `UserData`, and `DisplaysController` in the environment!
    static var section: Preferences.Section {
        Preferences.Section(title: "") {
            Preferences.Section.General.IsAppEnabledPreference()
            Preferences.Section.General.IsStartingOnLogonPreference()
            Preferences.Section.General.IsMenuLetEnabledPreference()
            Preferences.Section.General.PrimaryDisplayTriggerPreference()
        }
    }

    struct IsAppEnabledPreference: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        var body: some View {
            Toggle(isOn: $userData.isAppEnabled) {
                Text(LocalizedStringKey.Preferences.enabled)
            }
        }
    }

    struct IsStartingOnLogonPreference: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        var body: some View {
            Toggle(isOn: $controller.isStartingOnLogon) {
                Text(LocalizedStringKey.Preferences.start_on_logon)
            }
        }
    }

    struct IsMenuLetEnabledPreference: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        var body: some View {
            Toggle(isOn: $userData.isMenuletEnabled) {
                Text(LocalizedStringKey.Preferences.menulet_enabled)
            }
        }
    }

    struct PrimaryDisplayTriggerPreference: View {
        @EnvironmentObject private var controller: DisplaysController
        @EnvironmentObject private var userData: UserData

        @State private var primaryDisplay: Result<Display, BrightnessReadError> = .failure(.noDisplays(original: nil))

        var body: some View {
            VStack(alignment: .leading) {
                Text(LocalizedStringKey.Preferences.slider_header_text)
                    .font(.headline)

                switch primaryDisplay {
                case let .success(display):
                    TriggerSliderView(
                        display: display,
                        triggerValue: $userData.interfaceStyleSwitchTriggerValue
                    )
                case let .failure(error):
                    error
                }
            }
            .onReceive(controller.displayManager.$displays) { displays in
                guard let primaryDisplay = displays.first else {
                    self.primaryDisplay = .failure(.noDisplays(original: nil))
                    return
                }

                if let readError = primaryDisplay.error {
                    self.primaryDisplay = .failure(readError)
                    return
                }

                self.primaryDisplay = .success(primaryDisplay)
            }
        }
    }
}

struct PreferenceSectionGeneral_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Preferences.Section.General.section
                .environmentObject(UserData())
                .environmentObject(DisplaysController(userData: UserData()))
                .previewDisplayName("About")
        }
    }
}
