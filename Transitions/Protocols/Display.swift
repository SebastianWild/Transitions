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

extension BrightnessReading: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .success(reading):
            return ".success(\(reading))"
        case let .failure(error):
            return ".failure(\(error))"
        }
    }
}

protocol Display {
    var id: CGDirectDisplayID { get }
    var persistentIdentifier: PersistentIdentifier? { get }
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
            name: info?.displayProductName ?? (isInternalDisplay ? "Internal Display" : "External display \(id)"),
            id: id,
            info: info
        )
    }

    /// Returns an identifier that should persist across restarts
    var persistentIdentifier: PersistentIdentifier? {
        isInternalDisplay ? .internalDisplay : metadata.persistentIdentifier
    }
}

enum PersistentIdentifier: CustomStringConvertible, Hashable, Identifiable, Codable {
    case uuid(String)
    case internalDisplay
    case dynamic(vendorID: Int, productID: Int, serialNumber: Int)

    var id: String { description }

    var description: String {
        switch self {
        case let .uuid(identifier):
            return "\(identifier)"
        case .internalDisplay:
            return "internal-display"
        case let .dynamic(vendorID: vendorID, productID: productID, serialNumber: serialNumber):
            return "\(vendorID)-\(productID)-\(serialNumber)"
        }
    }
}

struct DisplayMetadata {
    let name: String
    let id: CGDirectDisplayID
    /// Additional info applicable to external (DDC) displays
    let info: Info?

    /// An identifier that should not change between app runs and system restarts
    ///
    /// - attention: This identifier has various formats
    var persistentIdentifier: PersistentIdentifier? {
        guard let details = info else { return nil }

        if let identifier = info?.uuid {
            return .uuid(identifier)
        } else {
            return .dynamic(vendorID: details.vendorId, productID: details.productId, serialNumber: details.serialNumber)
        }
    }

    // You can use IORegistryExplorer (Xcode additional tools)
    // to preview where these values come from
    struct Info {
        let displayProductName: String
        /// - attention: seems to be unreliable
        ///
        /// Samsung CRG9 - this is 0
        let serialNumber: Int
        let yearOfManufacture: Int
        let weekOfManufacture: Int
        let vendorId: Int
        let productId: Int
        let horizontalImageSize: Int
        let verticalImageSize: Int
        let uuid: String?

        init(
            displayProductName: String,
            serialNumber: Int,
            yearOfManufacture: Int,
            weekOfManufacture: Int,
            vendorId: Int,
            productId: Int,
            horizontalImageSize: Int,
            verticalImageSize: Int,
            uuid: String?
        ) {
            self.displayProductName = displayProductName
            self.serialNumber = serialNumber
            self.yearOfManufacture = yearOfManufacture
            self.weekOfManufacture = weekOfManufacture
            self.vendorId = vendorId
            self.productId = productId
            self.horizontalImageSize = horizontalImageSize
            self.verticalImageSize = verticalImageSize
            self.uuid = uuid
        }

        init?(from dictionary: NSDictionary) {
            guard
                let displayProductNameDict = dictionary[kDisplayProductName] as? NSDictionary,
                let displayName = displayProductNameDict[Locale.current.identifier] as? NSString,
                let yearOfManufacture = dictionary[kDisplayYearOfManufacture] as? Int,
                let weekOfManufacture = dictionary[kDisplayWeekOfManufacture] as? Int,
                let vendorId = dictionary[kDisplayVendorID] as? Int,
                let productId = dictionary[kDisplayProductID] as? Int,
                let horizontalImageSize = dictionary[kDisplayHorizontalImageSize] as? Int,
                let verticalImageSize = dictionary[kDisplayVerticalImageSize] as? Int
            else {
                return nil
            }
            // TODO: Check if this is applicable to other monitors as well
            let uuid = dictionary["kCGDisplayUUID"] as? String
            // TODO: Should we gracefully fail if other fields are not reliable?
            let serialNumber = (dictionary[kDisplaySerialNumber] as? Int) ?? 0

            self.init(
                displayProductName: displayName as String,
                serialNumber: serialNumber,
                yearOfManufacture: yearOfManufacture,
                weekOfManufacture: weekOfManufacture,
                vendorId: vendorId,
                productId: productId,
                horizontalImageSize: horizontalImageSize,
                verticalImageSize: verticalImageSize,
                uuid: uuid
            )
        }
    }
}
