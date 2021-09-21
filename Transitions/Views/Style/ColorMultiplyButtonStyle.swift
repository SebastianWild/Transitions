//
//  ColorMultiplyButtonStyle.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/14/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

struct ColorMultiplyButtonStyle: ButtonStyle {
    let pressedMultiplier: Color
    let notPressedMultiplier: Color

    init(
        pressedMultiplier: Color = .white,
        notPressedMultiplier: Color = .gray
    ) {
        self.pressedMultiplier = pressedMultiplier
        self.notPressedMultiplier = notPressedMultiplier
    }

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration
            .label
            .colorMultiply(configuration.isPressed ? pressedMultiplier : notPressedMultiplier)
    }
}
