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
    
    private let stepping = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Dark Mode Trigger")
            Slider(value: $selected, in: range, step: stepping)
            Text("Move the slider to adjust at what brightness level dark mode is triggered.")
        }
    }
}

struct BrightnessSliderView_Preview: PreviewProvider {
    static var previews: some View {
        BrightnessSliderView(selected: .constant(50), range: .constant(0.0...100.0))
    }
}
