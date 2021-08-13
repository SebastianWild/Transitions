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

final class UserData: ObservableObject {
    @Published var isAppEnabled: Bool = false
    @Published var interfaceStyleSwitchTriggerValue: Float = 27.0
    var isStartingOnLogon: Bool { LoginItem.enabled }

    private var changeHandler: AnyCancellable?
    private let userDefaults = UserDefaults.standard

    init() {
        // Synchronize to UserDefaults when values change
        changeHandler = Publishers.CombineLatest($isAppEnabled, $interfaceStyleSwitchTriggerValue)
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
