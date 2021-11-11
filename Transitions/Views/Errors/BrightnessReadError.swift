//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

extension BrightnessReadError: View {
    var body: some View {
        switch self {
        case let .readError(metadata, _):
            Text("Could not read brightness from \(metadata.name)")
        case .noDisplays:
            Text("No displays that support brightness reading found.")
        case .notPerformed:
            Text("Awaiting initial reading...")
        }
    }
}
