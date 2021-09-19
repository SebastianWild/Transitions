//
//  AppStrings.swift
//  Transitions
//
//  Created by Sebastian Wild on 6/27/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation
import SwiftUI

extension LocalizedStringKey {
    enum Preferences {
        static let quit = LocalizedStringKey("quit")
        static let general = LocalizedStringKey("general")
        static let about = LocalizedStringKey("about")
        static let enabled = LocalizedStringKey("preferences_enabled")
        static let start_on_logon = LocalizedStringKey("start_on_logon")
        static let slider_header_text = LocalizedStringKey("slider_header_text")
        static let slider_footnote_text = LocalizedStringKey("slider_footnote_text")
    }
}

protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

extension RawRepresentable where RawValue == String {
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
