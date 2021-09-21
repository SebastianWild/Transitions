//
//  ButtonToggleStyle.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/20/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

struct ButtonToggleStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    let highlighted: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.leading, .trailing], 8.0)
            .padding([.top, .bottom], 2.0)
            .foregroundColor(foregroundColor(configuration))
            .background(
                RoundedRectangle(cornerRadius: 5.0)
                    .strokeBorder(colorScheme == .dark ? Color.gray : Color.gray, lineWidth: 0.5)
                    .background(
                        RoundedRectangle(cornerRadius: 5.0)
                            .fill(fillColor(configuration))
                    )
            )
    }

    private func foregroundColor(_ configuration: Configuration) -> Color {
        var light: Color {
            configuration.isPressed || highlighted ? .white : .primary
        }

        var dark: Color {
            configuration.isPressed ? .white : .primary
        }

        switch colorScheme {
        case .light:
            return light
        case .dark:
            return dark
        @unknown default:
            return light
        }
    }

    private func fillColor(_ configuration: Configuration) -> Color {
        var light: Color {
            configuration.isPressed || highlighted ? .accentColor : .white
        }

        var dark: Color {
            configuration.isPressed || highlighted ? .accentColor : .secondary
        }

        switch colorScheme {
        case .light:
            return light
        case .dark:
            return dark
        @unknown default:
            return light
        }
    }
}
