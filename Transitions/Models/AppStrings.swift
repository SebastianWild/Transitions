//
//  AppStrings.swift
//  Transitions
//
//  Created by Sebastian Wild on 6/27/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum LocalizedStringKeys {
    enum Preferences: String, Localizable {
        case enabled = "preferences_enabled"
        case start_on_logon
        case slider_header_text
        case slider_footnote_text
        case quit
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
