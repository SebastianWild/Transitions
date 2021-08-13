//
//  ContentView.swift
//  Transitions
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var userData: UserData
    @EnvironmentObject private var controller: TransitionsController

    @State var primaryDisplay: Result<Display, BrightnessReadError> = .failure(.noDisplays(original: nil))

    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey.Preferences.general)
                .font(.headline)
            Toggle(isOn: $userData.isAppEnabled) {
                Text(LocalizedStringKey.Preferences.enabled)
            }
            Toggle(isOn: $userData.isStartingOnLogon) {
                Text(LocalizedStringKey.Preferences.start_on_logon)
            }
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

            HStack {
                Spacer()
                Button(LocalizedStringKey.Preferences.quit, action: { exit(0) })
            }
        }
        .padding()
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

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferencesView()
        }
    }
}
