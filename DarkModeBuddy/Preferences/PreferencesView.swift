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
            VStack(alignment: .center, spacing: 0) {
                Text("Dark Mode Trigger")
                // TODO: Need my own slider with functionality to show current brightness
                Slider(value: $userData.interfaceStyleSwitchTriggerValue, in: 0.0...1.0)
                Text("Move the slider to adjust at what brightness level dark mode is triggered.")
            }
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
