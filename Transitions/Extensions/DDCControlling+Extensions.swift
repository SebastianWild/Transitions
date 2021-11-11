//
//  DDCControlling+Extensions.swift
//  Transitions
//
//  Created by Sebastian Wild on 10/3/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import AppKit
import DDC
import Foundation

/*
 /// Wraps `DDC` module's `DDC` class, as some properties that we need to satisfy protocol requirements are internal
 class IntelDDCWrapper: DDCControlling {
     let displayID: CGDirectDisplayID

     private let intelDDC: DDC

     required init?(displayID: CGDirectDisplayID) {
         self.displayID = displayID
         guard let intelDDC = DDC(for: displayID) else {
             return nil
         }

         self.intelDDC = intelDDC
     }

     required init?(`for`: NSScreen) {
         guard
             let displayID = `for`.displayID,
             let intelDDC = DDC(for: displayID)
         else {
             return nil
         }

         self.displayID = displayID
         self.intelDDC = intelDDC
     }

     func readBrightness() -> Float {
         0.0     // TODO
     }

     func readDisplayName() -> String {
         "Intel-powered externalDisplay"
     }
 }
  */

extension DDC: DDCControlling {
    func readBrightness() -> BrightnessReading {
        // TODO: Check this
        .success(Float(read(command: .brightness)?.1 ?? 0))
    }

    func readDisplayName() -> String {
        // TODO: Check this
        edid()?.manufacturerString() ?? "N/A"
    }
}
