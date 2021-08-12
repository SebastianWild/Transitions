//
// Created by Sebastian Wild on 8/12/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation

/**
 The main controller that tracks available displays, changes in user settings,
 and uses those in order to toggle functionality of the app
 */
class TransitionsController {
    let displayManager = DisplayManager()

    private let userData: UserData
    private var darkModeController: DarkModeController?
    /// Will hold a subscriber listening on changes of the enabled status of the app
    private var enabledCancellable: AnyCancellable?
    /// Will hold a subscriber listening for display changes on the machine
    private var primaryDisplayUpdateCancellable: AnyCancellable?

    init(userData: UserData) {
        self.userData = userData
        setUp()
    }

    private func setUp() {
        enabledCancellable = userData.$isAppEnabled
            .sink { [weak self] isEnabled in
                guard let self = self else { return }

                if isEnabled {
                    self.primaryDisplayUpdateCancellable = self.makeDisplayUpdatePipeline()
                } else {
                    self.primaryDisplayUpdateCancellable?.cancel()
                }
            }
    }

    /// Builds the Combine pipelines that listen on brightness, display, and threshold changes
    /// and creates `DarkModeController`s that then toggle the system appearance as needed
    ///
    /// - Returns: `AnyCancellable` of the built pipeline
    private func makeDisplayUpdatePipeline() -> AnyCancellable {
        let primaryDisplayChangedHandler = displayManager.$displays
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .map(\.first) // The first display is the primary display
            .handleEvents(receiveOutput: { [weak self] display in
                if display == nil {
                    self?.darkModeController = nil
                }
            })
            .compactMap { $0 } // If there is no primary display, we cannot continue

        // Configure re-creating the DarkModeController when user preferences or displays change
        return Publishers.CombineLatest(primaryDisplayChangedHandler, userData.$interfaceStyleSwitchTriggerValue)
            .map { display, thresholdValue in
                DarkModeController(display: display, threshold: thresholdValue)
            }
            .sink { [weak self] controller in
                self?.darkModeController = controller
            }
    }
}
