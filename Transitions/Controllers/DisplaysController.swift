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
class DisplaysController {
    let displayManager = DisplayDetector()
    @Published var isStartingOnLogon: Bool = LoginItem.enabled

    private var darkModeController: DisplayController?
    /// Will hold a subscriber listening on changes of the enabled status of the app
    private var enabledCancellable: AnyCancellable?
    /// Will hold a subscriber listening on changes of the login item enabled status
    private var loginItemCancellable: AnyCancellable?
    /// Will hold a subscriber listening for display changes on the machine
    private var primaryDisplayUpdateCancellable: AnyCancellable?

    init(userData: UserData) {
        setUp(listeningOn: userData)
    }

    private func setUp(listeningOn userData: UserData) {
        enabledCancellable = userData.$isAppEnabled
            .sink { [weak self] isEnabled in
                guard let self = self else { return }

                if isEnabled {
                    self.primaryDisplayUpdateCancellable = self.makeDisplayUpdatePipeline(listeningOn: userData)
                } else {
                    self.primaryDisplayUpdateCancellable?.cancel()
                }
            }

        loginItemCancellable = $isStartingOnLogon
            .sink { isEnabled in
                LoginItem.enabled = isEnabled
            }
    }

    /// Builds the Combine pipelines that listen on brightness, display, and threshold changes
    /// and creates `DarkModeController`s that then toggle the system appearance as needed
    ///
    /// - Returns: `AnyCancellable` of the built pipeline
    private func makeDisplayUpdatePipeline(listeningOn userData: UserData) -> AnyCancellable {
        let primaryDisplayChangedHandler = displayManager.$displays
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .map(\.first) // The first display is the primary display
            .handleEvents(receiveOutput: { [weak self] display in
                if display == nil {
                    self?.darkModeController = nil
                }
            })
            .compactMap { $0 } // If there is no primary display, or it does not have a persistent identifier, we cannot continue

        // Configure re-creating the DarkModeController when user preferences or displays change
        return primaryDisplayChangedHandler
            .map { display -> AnyPublisher<(Display, Float), Never> in
                var triggerPublisher: AnyPublisher<Float, Never>
                if let persistentId = display.persistentIdentifier {
                    triggerPublisher = userData
                        .settingsPublisher(for: persistentId)
                        .map(\.switchValue)
                        .eraseToAnyPublisher()
                } else {
                    triggerPublisher = userData
                        .$defaultTriggerValue
                        .eraseToAnyPublisher()
                }

                return Publishers.CombineLatest(Just(display), triggerPublisher)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .map { display, thresholdValue in
                DisplayController(display: display, threshold: thresholdValue)
            }
            .sink { [weak self] controller in
                self?.darkModeController = controller
            }
    }
}

extension DisplaysController {
    /// Singleton shared instance `DisplaysController`.
    ///
    /// - attention: not thread safe
    static let main: DisplaysController = {
        DisplaysController(userData: .main)
    }()
}

extension DisplaysController: ObservableObject {}

extension DisplaysController: Refreshable {
    func refresh() {
        isStartingOnLogon = LoginItem.enabled
    }
}
