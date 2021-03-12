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
                let w = geometry.size.width
                let h = geometry.size.height

                // Make sure we do not exceed the size of the rectangle
                let cr = min(min(self.cornerRadius, h/2), w/2)
                
                // Let's define some important points in our indicator view
                let bottomCenter = CGPoint(x: w / 2, y: h)
                let leftCenter = CGPoint(x: 0, y: h / 2)
                let rightCenter = CGPoint(x: w, y: h / 2)
                let topCenter = CGPoint(x: w / 2, y: 0)
                let topLeft = CGPoint(x: 0, y: 0)
                let topRight = CGPoint(x: w, y: 0)
                
                // Origin is in the top left
                path.move(to: .init(x: topCenter.x, y: 0))        // Move to top middle
                // Top right corner
                path.addLine(to: .init(x: topRight.x - cr, y: topRight.y))
                path.addQuadCurve(to: .init(x: w, y: cr),
                                  control: topRight)
                // Middle right corner
                // TODO: Add Quad curve!
                path.addLine(to: rightCenter)
                // Bottom center
                path.addLine(to: bottomCenter)
                // Left center
                // TODO: Add quad curve!
                path.addLine(to: leftCenter)
                // Top Left
                path.addLine(to: .init(x: topLeft.x, y: topLeft.y + cr))
                path.addQuadCurve(to: .init(x: topLeft.x + cr, y: topLeft.y), control: .zero)
            }
        }
    }
}

struct PositionIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        PositionIndicatorView(cornerRadius: 1)
            .frame(width: 30, height: 30, alignment: .center)
    }
}
