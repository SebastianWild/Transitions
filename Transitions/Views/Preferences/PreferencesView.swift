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
                Text(LocalizedStringKeys.Preferences.enabled.rawValue)
            }
            Toggle(isOn: $userData.isStartingOnLogon) {
                Text(LocalizedStringKeys.Preferences.start_on_logon.rawValue)
            }
            VStack(alignment: .center, spacing: 0) {
                Text(LocalizedStringKeys.Preferences.slider_header_text.rawValue)
                BrightnessSliderView(
                    value: .constant(0.5),
                    innerValue: .constant(0.5),
                    range: 0.0 ... 1.0
                )
                Text(LocalizedStringKeys.Preferences.slider_footnote_text.rawValue)
                    .lineLimit(nil)
            }
            HStack {
                Spacer()
                Button(LocalizedStringKeys.Preferences.quit.rawValue, action: { exit(0) })
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
