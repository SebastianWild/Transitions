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
        VStack(spacing: 0) {
            Text("Dark Mode Trigger")
            // TODO: Need my own slider with functionality to show current brightness
            Slider(value: $selected, in: range)
            Text("Move the slider to adjust at what brightness level dark mode is triggered.")
        }
    }
}

struct BrightnessSliderView_Preview: PreviewProvider {
    static var previews: some View {
        BrightnessSliderView(selected: .constant(50), range: .constant(0.0...1.0))
    }
}
