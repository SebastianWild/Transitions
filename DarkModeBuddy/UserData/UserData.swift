//
//  UserData.swift
//  DarkModeBuddy
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

final class UserData: ObservableObject {
    @Published var isAppEnabled: Bool = false
    @Published var isStartingOnLogon: Bool = false
    @Published var interfaceStyleSwitchTriggerValue: Double = 0.0

    private var changeHandler: AnyCancellable?
    private let userDefaults = UserDefaults.standard

    init() {
        // Synchronize to UserDefaults when values change
        changeHandler = Publishers.CombineLatest3($isAppEnabled, $isStartingOnLogon, $interfaceStyleSwitchTriggerValue)
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] _ in
                guard let self = self else { return }

                UserDefaults.set(userData: self)
            }
    }
}

extension UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case isAppEnabled
        case isStartingOnLogon
        case interfaceStyleSwitchTriggerValue
    }

    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)

        isAppEnabled = try container.decode(Bool.self, forKey: .isAppEnabled)
        isStartingOnLogon = try container.decode(Bool.self, forKey: .isStartingOnLogon)
        interfaceStyleSwitchTriggerValue = try container.decode(Double.self, forKey: .interfaceStyleSwitchTriggerValue)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(isAppEnabled, forKey: .isAppEnabled)
        try container.encode(isStartingOnLogon, forKey: .isStartingOnLogon)
        try container.encode(interfaceStyleSwitchTriggerValue, forKey: .interfaceStyleSwitchTriggerValue)
    }
}
