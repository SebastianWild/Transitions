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
}

extension UserDefaults {
    func save<Item: Encodable>(item: Item, for key: String) throws {
        try set(JSONEncoder().encode(item), forKey: key)
    }

    func save<Item: Encodable>(item: Item, for key: UserDefaults.Keys) throws {
        try save(item: item, for: key.rawValue)
    }

    func get<Item: Decodable>(from key: String) -> Item? {
        guard let encoded = object(forKey: key) as? Data else { return nil }

        return try? JSONDecoder().decode(Item.self, from: encoded)
    }
}
