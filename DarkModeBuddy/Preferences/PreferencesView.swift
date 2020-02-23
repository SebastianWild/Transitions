//
//  ContentView.swift
//  DarkModeBuddy
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
                Text("Enabled")
            }
            Toggle(isOn: $userData.isStartingOnLogon) {
                Text("Start on Logon")
            }
            BrightnessSliderView(selected: $userData.interfaceStyleSwitchTriggerValue,
                                 range: .constant(0.0...100.0))
        }
        .padding()
    }
}


struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
            .environmentObject(UserData())
    }
}
