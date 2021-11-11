//
// Created by Sebastian Wild on 10/6/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum IORegUtils {
    static func service(for displayID: CGDirectDisplayID) -> IORegService? {
        guard let info = displayID.metadata.info else { return nil }
        // Not really right, we need to also take into account service locations
         return IORegService.forMatching()
            .sorted(by: { $0.matchScore(comparedTo: info) > $1.matchScore(comparedTo: info) })
            .first
    }
}

struct IORegService {
    var edidUUID: EDIDUUID = ""
    var productName: String = ""
    var serialNumber: Int = 0
    var service: IOAVService?
}

extension IORegService {
    typealias MatchScore = Int
    /// To be called when an `io_service_t` is found with class `DCPAVServiceProxy`
    /// previously the service should have been initialized with a call to `makeFromAppleCLCD2(service:)`
    ///
    /// - Parameter service: the `io_service_t` to use to create the needed `IOAVService`
    mutating func set(dcpAVServiceProxy service: io_service_t) {
        if IORegistryEntryCreateCFProperty(
            service,
            CFStringCreateWithCString(kCFAllocatorDefault, "Location", kCFStringEncodingASCII),
            kCFAllocatorDefault, IOOptionBits(kIORegistryIterateRecursively)
        ).takeRetainedValue() as? String == "External" {
            self.service = IOAVServiceCreateWithService(kCFAllocatorDefault, service)?.takeRetainedValue() as IOAVService
        }
    }

    /// Scores how likely the `Service` is to match what's returned by DisplayCreateInfoDictionary (`Info`)
    ///
    /// Higher numbers mean a greater likelihood
    /// - Parameter metadata:
    /// - Returns:
    func matchScore(comparedTo metadata: DisplayMetadata.Info) -> MatchScore {
        var score = 0
        // EDID UUID comparing
        if metadata.vendorId == edidUUID.vendorID {
            score += 1
        }
        if metadata.productId == edidUUID.productID {
            score += 1
        }
        if metadata.horizontalImageSize == edidUUID.horizontalImageSize {
            score += 1
        }
        if metadata.verticalImageSize == edidUUID.verticalImageSize {
            score += 1
        }
        if metadata.weekOfManufacture == edidUUID.manufactureDate.week {
            score += 1
        }
        if metadata.yearOfManufacture == edidUUID.manufactureDate.year {
            score += 1
        }

        if metadata.serialNumber == serialNumber {
            score += 1
        }
        if metadata.displayProductName == productName {
            score += 1
        }
    }

    /// All the `Service`s to be used for matching with DisplayCreateInfoDictionary for a specific CGDirectDisplayID
    static func forMatching() -> [IORegService] {
        var servicesForMatching = [IORegService]()
        var service = IORegService()
        for entry in IORegDisplayEntries() where entry.service != IO_OBJECT_NULL {
            // A `Service` needs both AppleCLCD2 and DCPAVServiceProxy
            if entry.class == .appleCLCD2 {
                service = IORegService.makeFromAppleCLCD2(service: entry.service)
            }
            if entry.class == .dcpAVServiceProxy {
                // Classes matched up, finish building the service
                service.set(dcpAVServiceProxy: entry.service)
                servicesForMatching.append(service)
            }
        }

        return servicesForMatching
    }

    /// Make a `Service` instance using the provided `io_service_t`
    ///
    /// - Parameter service: will be used to get edid uuid, display attributes and more using system APIs
    /// - Returns: New `Service` instance to be filled in later using a `DCPAVServiceProxy`
    static func makeFromAppleCLCD2(service: io_service_t) -> IORegService {
        let edidUUID = IORegistryEntryCreateCFProperty(
            service,
            CFStringCreateWithCString(kCFAllocatorDefault, "EDID UUID", kCFStringEncodingASCII),
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)
        ).takeRetainedValue() as? String

        let productAttributes = (IORegistryEntryCreateCFProperty(
            service,
            CFStringCreateWithCString(kCFAllocatorDefault, "DisplayAttributes", kCFStringEncodingASCII),
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)
        ).takeRetainedValue() as? NSDictionary)?.value(forKey: "ProductAttributes") as? NSDictionary

        let productName = productAttributes?.value(forKey: "ProductName") as? String
        let serialNumber = productAttributes?.value(forKey: "SerialNumber") as? Int

        return IORegService(edidUUID: edidUUID ?? "", productName: productName ?? "", serialNumber: serialNumber ?? 0, service: nil)
    }
}

extension IORegService.MatchScore {
    static var max: Int { 8 }
}

struct IORegDisplayEntries: Sequence, IteratorProtocol {
    private lazy var iterator: io_iterator_t? = {
        var it = io_iterator_t()
        guard IORegistryEntryCreateIterator(
            IORegistryGetRootEntry(kIOMasterPortDefault),
            "IOService",
            IOOptionBits(kIORegistryIterateRecursively),
            &it
        ) == KERN_SUCCESS
        else {
            return nil
        }

        return it
    }()

    mutating func next() -> Entry? {
        // swiftlint:disable:next identifier_name
        guard let it = iterator else { return nil }

        var service: io_service_t = IO_OBJECT_NULL
        let className = UnsafeMutablePointer<CChar>.allocate(capacity: MemoryLayout<io_name_t>.size)
        defer { className.deallocate() }

        service = IOIteratorNext(it)

        repeat {
            guard service != IO_OBJECT_NULL else {
                break
            }

            guard IORegistryEntryGetName(service, className) == KERN_SUCCESS else {
                service = IO_OBJECT_NULL
                break
            }

            if let ioRegClass = IORegDisplayEntryClass(rawValue: String(cString: className)) {
                return (ioRegClass, service)
            }
        } while service != IO_OBJECT_NULL

        return nil
    }
}

extension IORegDisplayEntries {
    typealias Entry = (class: IORegDisplayEntryClass, service: io_service_t)

    private static let ioRegClassesToMatch = IORegDisplayEntryClass.allCases.map(\.rawValue)
}

enum IORegDisplayEntryClass: String, CaseIterable {
    case appleCLCD2 = "AppleCLCD2"
    case dcpAVServiceProxy = "DCPAVServiceProxy"
}
