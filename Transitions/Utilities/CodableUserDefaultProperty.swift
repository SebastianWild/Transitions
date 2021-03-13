//
//  UserDefaultsWrapper.swift
//  Transitions
//
//  Created by Sebastian Wild on 3/12/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation

@propertyWrapper
struct CodableUserDefaultProperty<T: Codable> {
    private let defaults: UserDefaults
    private let key: String
    private let defaultValue: T

    init(_ key: String, defaultValue: T, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }

    public var wrappedValue: T {
        get {
            defaults.get(from: key) ?? defaultValue
        }
        set {
            try? defaults.save(item: newValue, for: key)
        }
    }
}

extension CodableUserDefaultProperty {
    init(_ key: UserDefaults.Keys, defaultValue: T, defaults: UserDefaults = .standard) {
        self.init(key.rawValue, defaultValue: defaultValue, defaults: defaults)
    }
}
