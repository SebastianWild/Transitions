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
    static var enabled: Bool {
        get {
            LSSharedFileList
                .sessionLoginItems
                .copiedSnapshot
                .transitionsApp != nil
        }
        set {
            let list = LSSharedFileList.sessionLoginItems
            let snapshot = list.copiedSnapshot

            guard newValue else {
                guard let transitionsItem = snapshot.transitionsApp else { return }
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

            LSSharedFileListInsertItemURL(list, snapshot.last ?? kLSSharedFileListItemLast.takeRetainedValue(), nil, nil, Bundle.cfURL, properties, nil)
        }
    }
}

private extension Bundle {
    static var cfURL: CFURL { URL(fileURLWithPath: Bundle.main.bundlePath) as CFURL }
}

private extension LSSharedFileList {
    static var sessionLoginItems: LSSharedFileList {
        LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)!.takeRetainedValue()
    }
}

private extension LSSharedFileList {
    var copiedSnapshot: [LSSharedFileListItem] {
        LSSharedFileListCopySnapshot(self, nil)!.takeRetainedValue() as? [LSSharedFileListItem] ?? []
    }
}

private extension Array where Element == LSSharedFileListItem {
    var transitionsApp: LSSharedFileListItem? {
        filter { LSSharedFileListItemCopyResolvedURL($0, 0, nil)!.takeRetainedValue() == Bundle.cfURL }
            .first
    }
}
