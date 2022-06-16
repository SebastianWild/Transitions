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

/// - attention: Not thread safe.
final class UserData: ObservableObject {
    // MARK: - User Preferences

    @Published var isAppEnabled: Bool = false
    @Published var interfaceStyleSwitchTriggerValue: Float = 0.27
    @Published var isMenuletEnabled: Bool = true

    @Published var perDisplaySettings: [String: DisplaySettings] = [:]

    // MARK: - Public Properties

    var isStartingOnLogon: Bool { LoginItem.enabled }

    // MARK: - Private Properties

    private var changeHandler: AnyCancellable?
    private let userDefaults = UserDefaults.standard

    init() {
        // Synchronize to UserDefaults when values change
        changeHandler = Publishers.CombineLatest3($isAppEnabled, $interfaceStyleSwitchTriggerValue, $isMenuletEnabled)
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
            .handleEvents(receiveOutput: { data in
                print("Received new user data: \(data)")
            })
            .sink { [weak self] _ in
                guard let self = self else { return }

                try? self.userDefaults.save(item: self, for: UserDefaults.Keys.userData)
            }
    }
}

// MARK: - UserData Helper Types

extension UserData {
    struct DisplaySettings: Codable, Identifiable {
        let id: String
        let interfaceStyleSwitchTriggerValue: Float
    }
}

// MARK: - Codable

extension UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case isAppEnabled
        case interfaceStyleSwitchTriggerValue
    }

    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)

        isAppEnabled = try container.decode(Bool.self, forKey: .isAppEnabled)
        interfaceStyleSwitchTriggerValue = try container.decode(Float.self, forKey: .interfaceStyleSwitchTriggerValue)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(isAppEnabled, forKey: .isAppEnabled)
        try container.encode(interfaceStyleSwitchTriggerValue, forKey: .interfaceStyleSwitchTriggerValue)
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
