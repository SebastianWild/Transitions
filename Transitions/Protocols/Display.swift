//
//  Display.swift
//  Transitions
//
//  Created by Sebastian Wild on 7/5/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

typealias BrightnessReading = Result<Float, BrightnessReadError>

protocol Display {
    var id: CGDirectDisplayID { get }
    var name: String { get set }
    /// Brightness for a display is defined from 0.0 to 1.0
    var brightness: Float { get }
    var error: BrightnessReadError? { get }
    var isInternalDisplay: Bool { get }

    var metadata: DisplayMetadata { get }

    var reading: AnyPublisher<BrightnessReading, Never> { get }
}

extension Display {
    var metadata: DisplayMetadata {
        let info = DisplayMetadata.Info(from: CoreDisplay_DisplayCreateInfoDictionary(id)?.takeRetainedValue() ?? NSDictionary())

        return DisplayMetadata(
            name: info?.displayProductName ?? name,
            id: id,
            info: info
        )
    }
}

struct DisplayMetadata {
    let name: String
    let id: CGDirectDisplayID
    /// Additional info applicable to external (DDC) displays
    let info: Info?

    /// An identifier that should not change between app runs and system restarts
    var persistentIdentifier: String? {
        guard let details = info else { return nil }

        return "\(details.vendorId)-\(details.productId)-\(details.serialNumber)"
    }

    // You can use IORegistryExplorer (Xcode additional tools)
    // to preview where these values come from
    struct Info {
        let displayProductName: String
        let serialNumber: Int
        let yearOfManufacture: Int
        let weekOfManufacture: Int
        let vendorId: Int
        let productId: Int
        let horizontalImageSize: Int
        let verticalImageSize: Int

        init(displayProductName: String, serialNumber: Int, yearOfManufacture: Int, weekOfManufacture: Int, vendorId: Int, productId: Int, horizontalImageSize: Int, verticalImageSize: Int) {
            self.displayProductName = displayProductName
            self.serialNumber = serialNumber
            self.yearOfManufacture = yearOfManufacture
            self.weekOfManufacture = weekOfManufacture
            self.vendorId = vendorId
            self.productId = productId
            self.horizontalImageSize = horizontalImageSize
            self.verticalImageSize = verticalImageSize
        }

        init?(from dictionary: NSDictionary) {
            guard
                let displayProductNameDict = dictionary[kDisplayProductName] as? NSDictionary,
                let displayName = displayProductNameDict[Locale.current.identifier] as? NSString,
                let serialNumber = dictionary[kDisplaySerialNumber] as? Int,
                let yearOfManufacture = dictionary[kDisplayYearOfManufacture] as? Int,
                let weekOfManufacture = dictionary[kDisplayWeekOfManufacture] as? Int,
                let vendorId = dictionary[kDisplayVendorID] as? Int,
                let productId = dictionary[kDisplayProductID] as? Int,
                let horizontalImageSize = dictionary[kDisplayHorizontalImageSize] as? Int,
                let verticalImageSize = dictionary[kDisplayVerticalImageSize] as? Int
            else {
                return nil
            }

            self.init(
                displayProductName: displayName as String,
                serialNumber: serialNumber,
                yearOfManufacture: yearOfManufacture,
                weekOfManufacture: weekOfManufacture,
                vendorId: vendorId,
                productId: productId,
                horizontalImageSize: horizontalImageSize,
                verticalImageSize: verticalImageSize
            )
        }
    }
}
