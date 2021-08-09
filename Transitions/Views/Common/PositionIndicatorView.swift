//
//  PositionIndicatorView.swift
//  Transitions
//
//  Created by Sebastian Wild on 2/23/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Foundation
import SwiftUI

struct PositionIndicatorView: View {
    let cornerRadius: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Make sure we do not exceed the size of the rectangle
                let cornerRadius = min(min(self.cornerRadius, height / 2), width / 2)

                // Let's define some important points in our indicator view
                let bottomCenter = CGPoint(x: width / 2, y: height)
                let leftCenter = CGPoint(x: 0, y: height / 2)
                let rightCenter = CGPoint(x: width, y: height / 2)
                let topCenter = CGPoint(x: width / 2, y: 0)
                let topLeft = CGPoint(x: 0, y: 0)
                let topRight = CGPoint(x: width, y: 0)

                // Origin is in the top left
                path.move(to: .init(x: topCenter.x, y: 0)) // Move to top middle
                // Top right corner
                path.addLine(to: .init(x: topRight.x - cornerRadius, y: topRight.y))
                path.addQuadCurve(to: .init(x: width, y: cornerRadius),
                                  control: topRight)
                // Middle right corner
                path.addLine(to: rightCenter)
                // Bottom center
                path.addLine(to: bottomCenter)
                // Left center
                path.addLine(to: leftCenter)
                // Top Left
                path.addLine(to: .init(x: topLeft.x, y: topLeft.y + cornerRadius))
                path.addQuadCurve(to: .init(x: topLeft.x + cornerRadius, y: topLeft.y), control: .zero)
            }
        }
        .foregroundColor(Color.Controls.slider_thumb)
        .padding(2.0)
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1.5)
        .contentShape(Rectangle())
    }
}

struct PositionIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        PositionIndicatorView(cornerRadius: 1)
            .frame(width: 30, height: 30, alignment: .center)
    }
}
