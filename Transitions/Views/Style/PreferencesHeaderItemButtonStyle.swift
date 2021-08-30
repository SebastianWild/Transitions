//
//  PreferencesHeaderItemButtonStyle.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/14/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

extension Preferences {
    struct Style: ButtonStyle {
        @State private var hovering: Bool = false

        func makeBody(configuration: ButtonStyleConfiguration) -> some View {
            ZStack {
                // TODO: Work this out, it's a bit weird
                configuration.label
                    .foregroundColor(configuration.isPressed ? .primary : .accentColor)
                    .onHover(perform: { hovering in
                        self.hovering = hovering
                    })
                    .background(
                        Rectangle()
                            .foregroundColor(hovering ? .gray : .clear)
                            .cornerRadius(7)
                    )
            }
        }

//        func backgroundColor(for config: ButtonStyleConfiguration) -> Color {
//            if config.isPressed {
//                return
//            }
//        }
    }
}
