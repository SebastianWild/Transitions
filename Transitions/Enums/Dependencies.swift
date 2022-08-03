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
    case launchAtLogin

    var description: Dependecy {
        switch self {
        case .preferences:
            return Dependecy(
                name: "swiftui-sliders",
                author: "SpaceNation Inc.",
                // swiftlint:disable:next force_unwrapping
                link: URL(staticString: "https://github.com/spacenation/swiftui-sliders"),
                license: .MIT
            )
        case .sliders:
            return Dependecy(
                name: "Preferences",
                author: "Sindre Sorhus",
                // swiftlint:disable:next force_unwrapping
                link: URL(staticString: "https://github.com/sindresorhus/Preferences"),
                license: .MIT
            )
        case .launchAtLogin:
            return Dependecy(
                name: "LaunchAtLogin",
                author: "Sindre Sorhus",
                // swiftlint:disable:next force_unwrapping
                link: URL(staticString: "https://github.com/sindresorhus/LaunchAtLogin"),
                license: .MIT
            )
        }
    }
}

private extension URL {
    init(staticString: StaticString) {
        guard let url = URL(string: "\(staticString)") else {
            preconditionFailure("Developer error")
        }
        self = url
    }
}
