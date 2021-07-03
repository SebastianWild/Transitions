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

    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $userData.isAppEnabled) {
                Text(LocalizedStringKey.Preferences.enabled)
            }
            Toggle(isOn: $userData.isStartingOnLogon) {
                Text(LocalizedStringKey.Preferences.start_on_logon)
            }
            VStack(alignment: .center, spacing: 0) {
                Text(LocalizedStringKey.Preferences.slider_header_text)
                BrightnessSliderView(
                    value: $userData.interfaceStyleSwitchTriggerValue,
                    innerValue: .constant(0.5),
                    range: 0.0 ... 1.0
                )
                Text(LocalizedStringKey.Preferences.slider_footnote_text)
                    .lineLimit(nil)
            }
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
