//
//  BrightnessSliderView.swift
//  Transitions
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Foundation
import SwiftUI

struct BrightnessSliderView: View {
    @Binding var value: Double
    @Binding var innerValue: Double
    let range: ClosedRange<Double>
    let step: Double

    @State private var indicatorPosition: CGPoint

    init(
        value: Binding<Double>,
        innerValue: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double
    ) {
        _value = value
        _innerValue = innerValue
        _indicatorPosition = State(initialValue: CGPoint(x: value.wrappedValue, y: Double(CGFloat.indicatorYOffset * -1)))
        self.range = range
        self.step = step
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let steps: Int = {
                    guard !range.isEmpty else { return 0 }

                    let pxPerStep = geometry.size.width / CGFloat(step)
                    return Int(pxPerStep / CGFloat(step))
                }()
                RoundedRectangle(cornerRadius: .cornerRadius, style: .continuous)
                    .fill(Color.sliderBar)
                    .frame(
                        minWidth: 100,
                        idealWidth: 100,
                        maxWidth: .infinity,
                        minHeight: .sliderHeight,
                        idealHeight: .sliderHeight,
                        maxHeight: .sliderHeight,
                        alignment: .center
                    )
                HStack(spacing: geometry.size.width / CGFloat(steps)) {
                    ForEach(0 ..< steps) { _ in
                        pill
                    }
                }
                PositionIndicatorView(cornerRadius: .indicatorCornerRadius)
                    .position(indicatorPosition)
                    .frame(width: .indicatorWidth, height: .indicatorHeight)
                    .offset(x: 0, y: .indicatorYOffset)
                    .gesture(drag)
            }
        }
        .padding([.top, .bottom])
    }

    var pill: some View {
        RoundedRectangle(cornerRadius: .pillCornerRadius)
            .fill(Color.sliderDivider)
            .frame(width: .pillWidth, height: .pillHeight)
            .fixedSize()
    }

    var drag: some Gesture {
        DragGesture()
            .onEnded { value in
                self.value = Double(value.location.y)
            }
    }
}

private extension CGFloat {
    static let sliderHeight: CGFloat = 5
    static let cornerRadius: CGFloat = 2

    static let pillCornerRadius: CGFloat = 1
    static let pillWidth: CGFloat = 2
    static let pillHeight: CGFloat = .sliderHeight + 4

    static var indicatorHeight: CGFloat = .indicatorWidth * 1.5
    static var indicatorWidth: CGFloat = 15
    static var indicatorCornerRadius: CGFloat = .pillCornerRadius
    static var indicatorYOffset: CGFloat = -10
}

private extension Color {
    static let sliderBar = Color("slider_bar").opacity(30.0)
    static let sliderDivider = Color("slider_divider").opacity(10.0)
}

struct BrightnessSliderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BrightnessSliderView(
                value: .constant(0.5),
                innerValue: .constant(0.5),
                range: 0.0 ... 1.0,
                step: 0.1
            )
//            Slider(
//                value: .constant(0.5),
//                in: 0 ... 1,
//                step: 0.1
//            )
        }
    }
}
