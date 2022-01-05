//
//  DisplayDarkModeTriggerSliderView.swift
//  Transitions
//
//  Created by Sebastian Wild on 7/8/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

struct TriggerSliderView: View {
    let display: Display
    @Binding var triggerValue: Float

    @State var reading: Float = 0.0

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                SliderView(
                    value: $triggerValue,
                    innerValue: display.brightness,
                    range: 0.0 ... 1.0,
                    label: display.name,
                    leftIcon: Image.sun_min
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.primary),
                    rightIcon: Image.sun_max
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.primary)
                )
            }
            Text(LocalizedStringKey.Preferences.slider_footnote_text)
                // Need to set fixed size in order to prevent word wrap issue
                // https://stackoverflow.com/a/56604599/30602
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .font(.footnote)
                .padding(.top)
        }
        .onReceive(display.reading) { reading in
            if case let .success(brightness) = reading {
                withAnimation {
                    self.reading = brightness
                }
            }
        }
    }
}

struct TriggerSliderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TriggerSliderView(display: Preview.MockDisplay(), triggerValue: .constant(0.4))
                .previewDisplayName("Normal state")
        }
    }
}
