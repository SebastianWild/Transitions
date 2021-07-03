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
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image.sun_min
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.primary)
                    BrightnessSliderView(
                        value: $userData.interfaceStyleSwitchTriggerValue,
                        innerValue: .constant(0.5),
                        range: 0.0 ... 1.0
                    )
                    Image.sun_max
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.primary)
                }
                Text(LocalizedStringKey.Preferences.slider_footnote_text)
                    // Need to set fixed size in order to prevent word wrap issue
                    // https://stackoverflow.com/a/56604599/30602
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
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
