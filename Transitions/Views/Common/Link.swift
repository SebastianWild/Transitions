//
//  Link.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/20/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

/// Standard SwiftUI `Link` is only on macOS 11 or newer - this is a rough (but less flexible) equivalent
struct Link: View {
    let label: String
    let destination: URL

    @State private var isHovering: Bool = false
    private let linkColor = Color.accentColor

    var body: some View {
        Text(label)
            .bold()
            .underline(isHovering, color: linkColor)
            .foregroundColor(linkColor)
            .onHover(perform: { hovering in
                isHovering = hovering
            })
            .onTapGesture {
                NSWorkspace.shared.open(destination)
            }
    }
}
