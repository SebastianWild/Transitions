//
//  PreferenceItemImageModifier.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/14/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

extension Image {
    func preferenceIconFormatted() -> some View {
        resizable()
            .renderingMode(.template)
            .frame(width: 50, height: 50)
    }
}
