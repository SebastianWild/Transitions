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

struct SliderView<LeftIcon: View, RightIcon: View>: View {
    @Binding var value: Float
    let innerValue: Float
    let range: ClosedRange<Float>
    let label: String

    private let leftIcon: LeftIcon
    private let rightIcon: RightIcon

    @State private var isPressed: Bool = false

    init(
        value: Binding<Float>,
        innerValue: Float,
        range: ClosedRange<Float>,
        label: String,
        leftIcon: @autoclosure () -> LeftIcon,
        rightIcon: @autoclosure () -> RightIcon
    ) {
        _value = value
        self.innerValue = innerValue
        self.range = range
        self.label = label

        self.leftIcon = leftIcon()
        self.rightIcon = rightIcon()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                leftIcon

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

                rightIcon
            }

            Text(label)
                .fontWeight(.semibold)
        }
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

    var ratioFilled: Float {
        innerValue / (range.upperBound - range.lowerBound)
    }
}

struct BrightnessSliderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SliderView(
                value: .constant(0.0),
                innerValue: 0.25,
                range: 0.0 ... 1.0,
                label: "Internal Display",
                leftIcon: Image.sun_min
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.primary),
                rightIcon: Image.sun_max
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.primary)
            )
        }
    }
}
