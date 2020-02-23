//
//  UserData.swift
//  DarkModeBuddy
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class UserData: ObservableObject {
    @Published var isAppEnabled: Bool = false
    @Published var isStartingOnLogon: Bool = false
    @Published var interfaceStyleSwitchTriggerValue: Double = 0.0
}
