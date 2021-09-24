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
    static var section: Preferences.Section {
        Preferences.Section(title: "") {
            Preferences.Section.General.Container()
        }
    }

    /// View for general app settings.
    ///
    /// Intended to be container in a `Preferences.Section`
    struct Container: View {
        @EnvironmentObject private var controller: DisplaysController
        @EnvironmentObject private var userData: UserData

        @State private var primaryDisplay: Result<Display, BrightnessReadError> = .failure(.noDisplays(original: nil))

        var body: some View {
            VStack(alignment: .leading) {
                Preferences.Section.General.Toggles()

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

    /// View for app settings that can be toggled,
    /// such as enabled, start on logon, menulet
    struct Toggles: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        var body: some View {
            Toggle(isOn: $userData.isAppEnabled) {
                Text(LocalizedStringKey.Preferences.enabled)
            }
            Toggle(isOn: $controller.isStartingOnLogon) {
                Text(LocalizedStringKey.Preferences.start_on_logon)
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
