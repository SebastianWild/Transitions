//
//  BrightnessSliderView.swift
//  Transitions
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import AppKit
import Foundation
import Sliders
import SwiftUI

struct BrightnessSliderView: View {
    @Binding var value: Double
    @Binding var innerValue: Double
    let range: ClosedRange<Double>

    @State private var isPressed: Bool = false

    init(
        value: Binding<Double>,
        innerValue: Binding<Double>,
        range: ClosedRange<Double>
    ) {
        _value = value
        _innerValue = innerValue
        self.range = range
    }

    var body: some View {
        ValueSlider(value: $value)
            .valueSliderStyle(
                HorizontalValueSliderStyle(
                    track: track
                        .frame(height: 6)
                        .cornerRadius(3),
                    thumb: thumb,
                    thumbSize: CGSize(width: CGSize.defaultThumbSize.width / 2, height: CGSize.defaultThumbSize.height)
                )
            )
            .fixedSize(horizontal: false, vertical: true)
    }

    var track: some View {
        GeometryReader { geo in
            ZStack {
                HorizontalRangeTrack(
                    view: Color.gray
                )
                .opacity(0.25)

                Rectangle()
                    .size(
                        .init(
                            width: CGFloat(ratioFilled) * geo.size.width,
                            height: geo.size.height
                        )
                    )
                    .foregroundColor(.accentColor)
            }
        }
    }

    var thumb: some View {
        Rectangle()
            .foregroundColor(isPressed ? Color.red : Color.Controls.slider_thumb)
            .cornerRadius(CGSize.defaultThumbSize.width / 2)
            .frame(width: CGSize.defaultThumbSize.width / 2, height: CGSize.defaultThumbSize.height)
            .shadow(radius: 1.0)
    }

    var ratioFilled: Double {
        innerValue / (range.upperBound - range.lowerBound)
    }
}

struct BrightnessSliderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BrightnessSliderView(
                value: .constant(0.0),
                innerValue: .constant(0.25),
                range: 0.0 ... 1.0
            )

            Slider(value: .constant(0.5))
        }
    }
}
