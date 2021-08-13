//
// Created by Sebastian Wild on 8/13/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum LoginItem {
    // TODO: Error handling?
    /**
     Adds or removed the login item for Transitions.app.

     pass `true` to
     */
    static var enabled: Bool? {
        get {
            guard let loginItem = LSSharedFileList
                .sessionLoginItems
                .copiedSnapshot
                .transitionsApp
            else {
                return nil
            }

            return LSSharedFileListItemCopyProperty(
                loginItem,
                kLSSharedFileListLoginItemHidden.takeRetainedValue()
            )?.takeRetainedValue() as? Bool
        }
        set {
            let list = LSSharedFileList.sessionLoginItems

            guard let enabled = newValue, enabled else {
                guard let transitionsItem = list.copiedSnapshot.transitionsApp else { return }
                LSSharedFileListItemRemove(list, transitionsItem)

                return
            }

            // Add the item
            let key = Unmanaged.passUnretained(kLSSharedFileListLoginItemHidden.takeRetainedValue()).toOpaque()
            let isHidden = Unmanaged.passUnretained(kCFBooleanFalse).toOpaque()
            // see: https://stackoverflow.com/a/5598992
            let properties = [
                key: isHidden
            ] as CFDictionary

            LSSharedFileListInsertItemURL(list, nil, nil, nil, Bundle.cfURL, properties, nil)
        }
    }
}

private extension Bundle {
    static var cfURL: CFURL { URL(fileURLWithPath: Bundle.main.bundlePath) as CFURL }
}

private extension LSSharedFileList {
    static var sessionLoginItems: LSSharedFileList {
        LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue()
    }
}

private extension LSSharedFileList {
    var copiedSnapshot: [LSSharedFileListItem] {
        LSSharedFileListCopySnapshot(self, nil).takeRetainedValue() as? [LSSharedFileListItem] ?? []
    }
}

private extension Array where Element == LSSharedFileListItem {
    var transitionsApp: LSSharedFileListItem? {
        filter { LSSharedFileListItemCopyResolvedURL($0, 0, nil).takeRetainedValue() == Bundle.cfURL }
            .first
    }
}
