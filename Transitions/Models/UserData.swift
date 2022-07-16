//
//  UserData.swift
//  Transitions
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

/// User data/preferences storage model and helpers.
///
/// - attention: Not thread safe.
final class UserData: ObservableObject, Loggable {
    // MARK: - User Preferences

    @Published var isAppEnabled: Bool = false
    @Published var isMenuletEnabled: Bool = true
    /// Should a display not support a persistent identifier and settings cannot be saved,
    /// this is the default trigger value.
    @Published var defaultTriggerValue: Float = 0.27
    @Published var displaySettings: [String: DisplaySettings] = [:]

    // MARK: - Public Properties

    var isStartingOnLogon: Bool { LoginItem.enabled }

    // MARK: - Private Properties

    private var changeHandler: AnyCancellable?
    private let userDefaults = UserDefaults.standard

    init() {
        // Synchronize to UserDefaults when values change
        changeHandler = objectWillChange
            .receive(on: DispatchQueue.main)
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] _ in
                guard let self = self else { return }

                do {
                    try self.userDefaults.save(item: self, for: UserDefaults.Keys.userData)
                    self.log.info("""
                    Saved new UserData:
                    \(self)
                    """)
                } catch {
                    self.log.error("""
                    Error when saving UserData!
                    \(error.localizedDescription)
                    """)
                }
            }
    }
}

// MARK: - UserData Helper Types

extension UserData {
    struct DisplaySettings: Codable, Identifiable {
        let id: String
        var switchValue: Float

        init(id: String, interfaceStyleSwitchTriggerValue: Float = 0.27) {
            self.id = id
            switchValue = interfaceStyleSwitchTriggerValue
        }
    }
}

// MARK: - Convenience APIs

extension UserData {
    /// Create a publisher that will fire when the settings for a display are changed.
    ///
    /// - Attention: if the display with the passed identifier does not have settings in `UserData`, it will be created
    /// - Parameter persistentIdentifier: The display for which to publish changes of the settings for.
    /// - Returns: Non-failing publisher that fires when the `DisplaySettings` are changed.
    func settingsPublisher(for persistentIdentifier: Display.PersistentIdentifier) -> AnyPublisher<DisplaySettings, Never> {
        if displaySettings[persistentIdentifier] == nil {
            displaySettings[persistentIdentifier] = DisplaySettings(id: persistentIdentifier)
        }

        return $displaySettings
            .compactMap { $0[persistentIdentifier] }
            .eraseToAnyPublisher()
    }

    /// Get a `Binding` to the `DisplaySettings.switchValue` for a `Display`.
    ///
    /// - Parameter persistentIdentifier: The identifier for the display. If `UserData` does not contain this display already, default settings will be created.
    /// - Returns: `Binding` where the `switchValue` can be changed for the display
    func switchBinding(for persistentIdentifier: Display.PersistentIdentifier) -> Binding<Float> {
        if displaySettings[persistentIdentifier] == nil {
            displaySettings[persistentIdentifier] = DisplaySettings(id: persistentIdentifier)
        }

        return Binding(
            get: { [weak self] in
                self?.displaySettings[persistentIdentifier]?.switchValue ?? 0.0
            },
            set: { [weak self] newValue in
                guard let self = self else {
                    return
                }

                self.displaySettings[persistentIdentifier]?.switchValue = newValue
            }
        )
    }
}

extension UserData: CustomStringConvertible {
    public var description: String {
        """
        UserData(
            isAppEnabled: \(isAppEnabled),
            isMenuletEnabled: \(isMenuletEnabled),
            displaySettings: \(displaySettings),
        )
        """
    }
}

// MARK: - Codable

extension UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case isAppEnabled
        case defaultTriggerValue
        case displaySettings
    }

    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)

        isAppEnabled = try container.decode(Bool.self, forKey: .isAppEnabled)
        defaultTriggerValue = try container.decode(Float.self, forKey: .defaultTriggerValue)
        displaySettings = try container.decode([String: UserData.DisplaySettings].self, forKey: .displaySettings)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(isAppEnabled, forKey: .isAppEnabled)
        try container.encode(defaultTriggerValue, forKey: .defaultTriggerValue)
        try container.encode(displaySettings, forKey: .displaySettings)
    }
}

// MARK: - Singleton

extension UserData {
    /// Singleton shared instance `UserData`.
    ///
    /// - attention: not thread safe
    static let main: UserData = {
        UserDefaults.standard.get(
            from: UserDefaults.Keys.userData.rawValue
        ) ?? UserData()
    }()
}
