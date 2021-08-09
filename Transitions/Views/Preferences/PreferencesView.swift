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
//    @EnvironmentObject private var displayManager: DisplayManager

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
            TriggerSliderView(
                display: Preview.MockDisplay(),
                triggerValue: $userData.interfaceStyleSwitchTriggerValue
            )
            HStack {
                Spacer()
                Button(LocalizedStringKey.Preferences.quit, action: { exit(0) })
            }
        }
        .padding()
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferencesView()
                .environmentObject(UserData())
        }
    }
}
