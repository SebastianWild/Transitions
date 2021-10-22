//
// Created by Sebastian Wild on 10/6/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Foundation

enum IORegUtils {
    static func service(for displayID: CGDirectDisplayID) -> Service? {
        let info = displayID.metadata.info
        return nil
    }
}

struct Service {
    let edidUUID: String
    let productName: String
    var service: IOAVService?
}

extension Service {
    static func makeFromAppleCLCD2(service: io_service_t) -> Service {
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

        return Service(edidUUID: edidUUID ?? "", productName: productName ?? "", service: nil)
    }

    private mutating func set(dcpAVServiceProxy service: io_service_t) {
        if IORegistryEntryCreateCFProperty(
            service,
            CFStringCreateWithCString(kCFAllocatorDefault, "Location", kCFStringEncodingASCII),
            kCFAllocatorDefault, IOOptionBits(kIORegistryIterateRecursively)
        ).takeRetainedValue() as? String == "External" {
            self.service = IOAVServiceCreateWithService(kCFAllocatorDefault, service)?.takeRetainedValue() as IOAVService
        }
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
