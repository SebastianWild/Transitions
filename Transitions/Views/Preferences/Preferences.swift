//
//  Preferences.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/14/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation
import SwiftUI

struct Preferences: View {
    @EnvironmentObject private var userData: UserData
    @EnvironmentObject private var controller: TransitionsController

    @State private var selected: Section = .general

    var body: some View {
        VStack {
            HStack {
                Section.general.header(onSwitch: { onSwitch(to: $0) })
                Section.about.header(onSwitch: { onSwitch(to: $0) })
            }
            
            Divider()
            
            selected
        }
        .padding()
    }

    private func onSwitch(to section: Section) {
        selected = section
    }
}

extension Preferences {
    enum Section: PreferencesSection {
        case general
        case about

        var body: some View {
            switch self {
            case .general:
                General()
            case .about:
                About()
            }
        }
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Preferences()
                .environmentObject(UserData())
                .environmentObject(TransitionsController(userData: UserData()))
                .previewDisplayName("Preferences Pane")
        }
    }
}
