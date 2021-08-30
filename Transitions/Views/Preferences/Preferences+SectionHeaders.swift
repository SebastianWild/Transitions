//
//  Preferences+SectionHeaders.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/29/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

// swiftlint:disable multiple_closures_with_trailing_closure

import Foundation
import SwiftUI

extension Preferences {
    struct HeaderItem<Content: View>: View {
        let action: () -> Void

        @ViewBuilder let content: Content

        var body: some View {
            Button(action: self.action) {
                content
            }
            .buttonStyle(Preferences.Style())
        }
    }
}

extension Preferences.Section {
    @ViewBuilder func header(onSwitch: @escaping (Preferences.Section) -> Void) -> some View {
        switch self {
        case .general:
            Preferences.HeaderItem(
                action: { onSwitch(.general) }
            ) {
                VStack {
                    Image("gear")
                        .preferenceIconFormatted()
                    Text("General")
                }
            }
        case .about:
            Preferences.HeaderItem(
                action: { onSwitch(.about) }
            ) {
                VStack {
                    Image("gear")
                        .preferenceIconFormatted()
                    Text("About")
                }
            }
        }
    }
}

struct PreferencesHeaders_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Preferences.Section.general.header(onSwitch: { _ in })
                .previewDisplayName("General button")

            Preferences.Section.about.header(onSwitch: { _ in })
                .previewDisplayName("About button")
        }
    }
}
