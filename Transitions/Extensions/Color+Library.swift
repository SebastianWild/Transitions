//
//  Color+Library.swift
//  Transitions
//
//  Created by Sebastian Wild on 6/27/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

// swiftlint:disable nesting

import Foundation
import SwiftUI

extension Color {
    enum Controls {
        static let slider_thumb = Color("slider_thumb")
    }

    enum Preferences {
        enum SectionHeader {
            enum Background {
                /// The section header is currently being pressed
                static let pressed = Color("preferences_section_header_background_pressed")
                /// The section header is currently selected / the active section
                static let selected = Color("preferences_section_header_background_selected")
                /// The section header is currently being hovered over by the pointer
                static let hovering = Background.selected
                /// The section header is currently neither pressed, selected, or being hovered over
                static let none = Color.clear
            }

            enum Tint {
                /// The section header is currently being pressed
                static let pressed = Color("preferences_section_header_tint_pressed")
                /// The section header is currently selected / the active section
                static let selected = Color.accentColor
                /// The section header is currently being hovered over by the pointer
                static let highlighted = Tint.normal
                static let hoveringOverSelected = Tint.selected
                /// The section header is currently neither pressed, selected, or being hovered over
                static let normal = Color("preferences_section_header_tint_normal")
            }
        }
    }
}
