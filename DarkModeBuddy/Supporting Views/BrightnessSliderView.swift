//
//  BrightnessSliderView.swift
//  DarkModeBuddy
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Foundation
import SwiftUI

struct BrightnessSliderView: View {
    @Binding var selected: Double
    @Binding var range: ClosedRange<Double>
    private let stepping = 0.025

    var body: some View {
        Text("Hi")
    }
}

struct BrightnessSliderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BrightnessSliderView(selected: .constant(50), range: .constant(0.0 ... 1.0))
            Slider(value: .constant(0.5), in: 0.0 ... 50)
        }
    }
}
