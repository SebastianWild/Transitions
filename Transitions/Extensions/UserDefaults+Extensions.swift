//
//  UserDefaults+Save.swift
//  Transitions
//
//  Created by Sebastian Wild on 2/22/20.
//  Copyright © 2020 Sebastian Wild. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Keys: String {
        case userData
    }

    class var userData: UserData { standard.set(from: Keys.userData.rawValue) ?? UserData() }
    class func set(userData: UserData) { try? standard.save(item: userData, with: Keys.userData.rawValue) }
}

extension UserDefaults {
    func save<Item: Encodable>(item: Item, with key: String) throws {
        try set(JSONEncoder().encode(item), forKey: key)
    }

    func set<Item: Decodable>(from key: String) -> Item? {
        guard let encoded = object(forKey: key) as? Data else { return nil }

        return try? JSONDecoder().decode(Item.self, from: encoded)
    }
}
