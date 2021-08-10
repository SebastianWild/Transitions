//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

class DisplayManager: ObservableObject {
    @Published private(set) var displays: [Display] = []

    private var nsScreenUpdateCancellable: AnyCancellable?

    init(
        _ notificationCenter: NotificationCenter = .default
    ) {
        nsScreenUpdateCancellable = notificationCenter.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDisplays()
            }
        updateDisplays()
    }

    private func updateDisplays() {
        var displays = [Display]()
        // Pretty sure there is no mac with two internal displays?
        if let internalDisplay = try? InternalDisplay() {
            displays.append(internalDisplay)
        }

        self.displays = displays
    }
}
