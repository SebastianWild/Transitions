//
// Created by Sebastian Wild on 8/13/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum LoginItem {
    static var enabled: Bool {
        get {
            false
        }
        set {
            guard newValue else {
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
