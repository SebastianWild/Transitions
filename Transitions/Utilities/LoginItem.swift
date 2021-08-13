//
// Created by Sebastian Wild on 8/13/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum LoginItem {

    /**
     Adds or removed the login item for Transitions.app.

     pass `true` to
     */
    static var enabled: Bool? {
        get {
            guard let loginItem = transitionsSharedFileListItem else { return nil }

            return LSSharedFileListItemCopyProperty(
                    loginItem,
                    kLSSharedFileListLoginItemHidden.takeRetainedValue()
            )?.takeRetainedValue() as? Bool
        }
        set {
            guard let enabled = newValue, enabled else {
                guard let transitionsItem = transitionsSharedFileListItem else { return }
                LSSharedFileListItemRemove(sharedFileList, transitionsItem)

                return
            }

            // Add the item
            let key = Unmanaged.passUnretained(kLSSharedFileListLoginItemHidden.takeRetainedValue()).toOpaque()
            let isHidden = Unmanaged.passUnretained(kCFBooleanFalse).toOpaque()
            // see: https://stackoverflow.com/a/5598992
            let properties = [
                key: isHidden
            ] as CFDictionary

            LSSharedFileListInsertItemURL(sharedFileList, nil, nil, nil, bundleCFURL, properties, nil)
        }
    }
}

extension LoginItem {
    private static var bundleCFURL: CFURL { URL(fileURLWithPath: Bundle.main.bundlePath) as CFURL }

    private static var transitionsSharedFileListItem: LSSharedFileListItem? {
        sharedFileListItems
            .filter { LSSharedFileListItemCopyResolvedURL($0, 0, nil).takeRetainedValue() == bundleCFURL }
            .first
    }

    private static var sharedFileList: LSSharedFileList {
        LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue()
    }

    private static var sharedFileListItems: [LSSharedFileListItem] {
        LSSharedFileListCopySnapshot(sharedFileList, nil).takeRetainedValue() as? [LSSharedFileListItem] ?? []
    }
}
