//
//  PreferenceSection.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/29/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

// swiftlint:disable type_name

import Foundation
import SwiftUI

protocol PreferencesSection: View {
    associatedtype V

    func header(onSwitch: @escaping (Preferences.Section) -> Void) -> V
}
