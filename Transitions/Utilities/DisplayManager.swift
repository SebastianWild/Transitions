//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

/// `DisplayManager` is responsible for detecting available displays
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
        displays = NSScreen.screens
            .compactMap { screen -> Display? in
                screen.isInternalDisplay ? InternalDisplay(screen: screen) : DDCDisplay(screen)
            }
    }
}
