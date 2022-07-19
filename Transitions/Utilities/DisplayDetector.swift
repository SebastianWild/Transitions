//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

/// `DisplayDetector` is responsible for detecting available displays
class DisplayDetector: ObservableObject {
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
        displays = NSScreen.screens
            .compactMap { screen -> Display? in
                screen.isInternalDisplay ? try? InternalDisplay(screen: screen) : DDCDisplay(screen)
            }
    }
}
