//
//  ToggleButtonStyle.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/20/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

struct ToggleButtonStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }, label: {
            configuration.label
        })
            .buttonStyle(ButtonToggleStyle(highlighted: configuration.isOn))
    }
}
