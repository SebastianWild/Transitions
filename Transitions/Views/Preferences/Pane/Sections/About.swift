//
//  About.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/23/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Preferences
import SwiftUI

extension Preferences.Section.About {
    static var section: Preferences.Section {
        Preferences.Section(title: "") {
            Container()
        }
    }

    /// View showing "about" info for the app.
    ///
    /// Intended to be container in a `Preferences.Section`
    struct Container: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        @State private var mitTextExpanded: Bool = false

        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(Bundle.main.displayName)
                        .bold()
                        .font(.largeTitle)
                    Text("\("version".localized): \(Bundle.main.shortVersionString)")
                        .bold()
                    Text("© \("author".localized)")
                    Text(LocalizedStringKey.Preferences.about_description)
                }

                Divider()

                HStack {
                    Text("Libraries under MIT license")
                        .bold()
                    Toggle("􀐸", isOn: $mitTextExpanded)
                        .toggleStyle(ToggleButtonStyle())
                }

                if mitTextExpanded {
                    Text(License.MIT.text)
                        .font(.subheadline)
                        .lineLimit(nil)
                        // Needed to fix weird expansion issues with text.
                        // Without this the text upon expansion does not go beyond one line
                        // https://stackoverflow.com/a/58335789
                        .fixedSize(horizontal: false, vertical: true)
                        .padding([.bottom], 5.0)
                    // TODO: Smooth animation when expanding!
                }

                HStack {
                    ForEach(Dependencies.allCases.indices) {
                        Dependencies.allCases[$0].description
                    }
                }
            }
            .addTopTrailingView(
                Image.appIcon
                    .frame(width: 64, height: 64)
            )
        }
    }
}

private extension View {
    func addTopTrailingView<V: View>(_ view: V) -> some View {
        ZStack(alignment: .topTrailing) {
            view

            self
        }
    }
}

struct PreferenceSectionAbout_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Preferences.Section.About.section
                .environmentObject(UserData())
                .environmentObject(DisplaysController(userData: UserData()))
                .previewDisplayName("About")
        }
    }
}
