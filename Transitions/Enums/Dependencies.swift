//
//  Dependencies.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/20/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum Dependencies: CaseIterable {
    case preferences
    case sliders

    var description: Dependecy {
        switch self {
        case .preferences:
            return Dependecy(
                name: "swiftui-sliders",
                author: "SpaceNation Inc.",
                // swiftlint:disable:next force_unwrapping
                link: URL(string: "https://github.com/spacenation/swiftui-sliders")!,
                license: .MIT
            )
        case .sliders:
            return Dependecy(
                name: "Preferences",
                author: "Sindre Sorhus",
                // swiftlint:disable:next force_unwrapping
                link: URL(string: "https://github.com/sindresorhus/Preferences")!,
                license: .MIT
            )
        }
    }
}
