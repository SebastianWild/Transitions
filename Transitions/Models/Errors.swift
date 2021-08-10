//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum BrightnessReadError: LocalizedError {
    // TODO: Add localization strings for this!
    /// The brightness of the display could not be read.
    ///
    /// For internal displays, this can occur when there lid is closed or the internal display is off.
    case readError(displayMetadata: DisplayMetadata, original: Error?)
    /// There are no displays where brightness can be read from.
    case noDisplays(original: Error?)
}
