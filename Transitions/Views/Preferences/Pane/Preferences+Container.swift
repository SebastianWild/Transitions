//
//  Preferences+General.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/23/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Preferences
import SwiftUI

extension Preferences.Container {
    struct General: View {
        var body: some View {
            Preferences.Container(contentWidth: Preferences.contentWidth) {
                Preferences.Section.General.section
            }
        }
    }

    struct About: View {
        var body: some View {
            Preferences.Container(contentWidth: Preferences.contentWidth) {
                Preferences.Section.About.section
            }
        }
    }
}

struct PreferenceContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Preferences.Container.General()
                .environmentObject(UserData())
                .environmentObject(DisplaysController(userData: UserData()))
                .previewDisplayName("General")
            Preferences.Container.About()
                .environmentObject(UserData())
                .environmentObject(DisplaysController(userData: UserData()))
                .previewDisplayName("About")
        }
    }
}
