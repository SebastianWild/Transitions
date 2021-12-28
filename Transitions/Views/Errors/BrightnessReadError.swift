//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

extension BrightnessReadError: View {
    var body: some View {
        switch self {
        case let .readError(metadata, _):
            guard let name = metadata?.name else {
                return Text("Could not read brightness from the external display.")
            }
            return Text("Could not read brightness from \(name)")
        case .noDisplays:
            return Text("No displays that support brightness reading found.")
        case .notPerformed:
            return Text("Awaiting initial reading...")
        }
    }
}
