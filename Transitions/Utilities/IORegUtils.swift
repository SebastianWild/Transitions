//
// Created by Sebastian Wild on 10/6/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

/*
 Other TODOs:
 - MacMini9,1's HDMI port does not work with DDC
 */

enum IORegUtils: Loggable {
    static func service(for displayID: CGDirectDisplayID) -> IORegService? {
        guard displayID.metadata.info != nil else {
            log.warning("Attempted to get IOReg service for display does not have info!")
            return nil
        }
        return IORegService.forMatching()
            .sorted(by: { $0.matchScore(comparedTo: displayID.metadata) > $1.matchScore(comparedTo: displayID.metadata) })
            .first
    }
}

struct IORegService: Loggable {
    var edidUUID: EDIDUUID = ""
    var productName: String = ""
    var serialNumber: Int = 0
    var serviceLocation: Int = 0
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
    func matchScore(comparedTo metadata: DisplayMetadata) -> MatchScore {
        guard let info = metadata.info else { return -1 }

        log.info("""
                 Scoring display \(metadata.id) against service:
                 \(debugDescription)
                 """)

        var score = 0
        // EDID UUID comparing
        if info.vendorId == edidUUID.vendorID {
            score += 1
            log.debug("Vendor ID match. Score \(score)")
        }
        if info.productId == edidUUID.productID {
            score += 1
            log.debug("Product ID match. Score \(score)")
        }
        if info.horizontalImageSize == edidUUID.horizontalImageSize {
            score += 1
            log.debug("Horizontal image size match. Score \(score)")
        }
        if info.verticalImageSize == edidUUID.verticalImageSize {
            score += 1
            log.debug("Vertical image size match. Score \(score)")
        }
        if info.weekOfManufacture == edidUUID.manufactureDate?.week {
            score += 1
            log.debug("Week of manufacture match. Score \(score)")
        }
        if info.yearOfManufacture == edidUUID.manufactureDate?.year {
            score += 1
            log.debug("Year of manufacture match. Score \(score)")
        }

        if info.serialNumber == serialNumber {
            score += 1
            log.debug("Serial number match. Score \(score)")
        }
        if info.displayProductName == productName {
            score += 1
            log.debug("Display product name match. Score \(score)")
        }

        if serviceLocation == metadata.id {
            score += 1
            log.debug("Service location match. Score \(score)")
        }

        log.debug("""
                  Scoring for service
                  \(debugDescription)
                  complete. Final score \(score) / \(IORegService.MatchScore.max)
                  """)
        return score
    }

    /// All the `Service`s to be used for matching with DisplayCreateInfoDictionary for a specific CGDirectDisplayID
    static func forMatching() -> [IORegService] {
        log.debug("Starting IOReg search.")

        var servicesForMatching = [IORegService]()
        var service = IORegService()
        var serviceLocation = 0
        for entry in IORegDisplayEntries() where entry.service != IO_OBJECT_NULL {
            // A `Service` needs both AppleCLCD2 and DCPAVServiceProxy
            if entry.class == .appleCLCD2 {
                log.debug("Found AppleCLCD2 service. Creating IORegService.")
                serviceLocation += 1
                service = IORegService.makeFromAppleCLCD2(service: entry.service, location: serviceLocation)
            }
            if entry.class == .dcpAVServiceProxy {
                log.debug("Found DCPAVServiceProxy service. Appending service for matching.")
                // Classes matched up, finish building the service
                service.set(dcpAVServiceProxy: entry.service)
                servicesForMatching.append(service)
            }
        }
        log.debug("Found \(servicesForMatching.count) services for matching.")
        return servicesForMatching
    }

    /// Make a `Service` instance using the provided `io_service_t`
    ///
    /// - Parameter service: will be used to get edid uuid, display attributes and more using system APIs
    /// - Parameter location: The location integer to set in the IORegService structure
    /// - Returns: New `Service` instance to be filled in later using a `DCPAVServiceProxy`
    static func makeFromAppleCLCD2(service: io_service_t, location: Int) -> IORegService {
        let edidUUID = IORegistryEntryCreateCFProperty(
            service,
            CFStringCreateWithCString(kCFAllocatorDefault, "EDID UUID", kCFStringEncodingASCII),
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)
        )?.takeRetainedValue() as? String

        let productAttributes = (IORegistryEntryCreateCFProperty(
            service,
            CFStringCreateWithCString(kCFAllocatorDefault, "DisplayAttributes", kCFStringEncodingASCII),
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)
        )?.takeRetainedValue() as? NSDictionary)?.value(forKey: "ProductAttributes") as? NSDictionary

        let productName = productAttributes?.value(forKey: "ProductName") as? String
        let serialNumber = productAttributes?.value(forKey: "SerialNumber") as? Int

        log.debug(
            """
            Creating IORegService:
            EDID UUID: \(edidUUID ?? "nil"),
            ProductName: \(productName ?? "nil"),
            SerialNumber: \(serialNumber == nil ? "nil" : "\(serialNumber!)")
            Location: \(location),
            service: nil
            """
        )

        return IORegService(
            edidUUID: edidUUID ?? "",
            productName: productName ?? "",
            serialNumber: serialNumber ?? 0,
            serviceLocation: location,
            service: nil
        )
    }
}

extension IORegService.MatchScore {
    static var max: Int { 9 }
}

extension IORegService: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        IORegService(
            edidUUID: \(edidUUID),
            productName: \(productName),
            serialNumber: \(serialNumber),
            serviceLocation: \(serviceLocation)
        )
        """
    }
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
            } else {
                service = IOIteratorNext(it)
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
