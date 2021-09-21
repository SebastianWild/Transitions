//
//  Bundle+Extensions.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/19/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation

extension Bundle {
    var shortVersionString: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "N/A"
    }

    var displayName: String {
        (infoDictionary?["CFBundleDisplayName"] as? String) ?? "Transitions"
    }
}
