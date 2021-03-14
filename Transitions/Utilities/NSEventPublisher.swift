//
//  NSEventPublisher.swift
//  Transitions
//
//  Created by Sebastian Wild on 3/13/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Cocoa
import Combine

struct NSEventPublisher<Event: NSEvent>: Publisher {
    typealias Output = NSEvent
    typealias Failure = Never

    let eventMask: NSEvent.EventTypeMask

    init(_ mask: NSEvent.EventTypeMask) {
        eventMask = mask
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == NSEventPublisher.Failure, S.Input == NSEventPublisher.Output {
        let subscription = NSEventSubscription(subscriber: subscriber, mask: eventMask)
        subscriber.receive(subscription: subscription)
    }
}

final class NSEventSubscription<SubscriberType: Subscriber, Event: NSEvent>: Subscription where SubscriberType.Input == NSEvent {
    private var subscriber: SubscriberType?
    private let eventMask: NSEvent.EventTypeMask
    private var monitor: Any?

    init(subscriber: SubscriberType, mask: NSEvent.EventTypeMask) {
        self.subscriber = subscriber
        eventMask = mask
    }

    deinit {
        cancel()
    }

    func request(_: Subscribers.Demand) {
        guard monitor == nil else { return }

        monitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] event in
            _ = self?.subscriber?.receive(event)
        }
    }

    func cancel() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        subscriber = nil
    }
}

extension NSEvent {
    static func publisher(for eventMask: NSEvent.EventTypeMask) -> NSEventPublisher<NSEvent> {
        NSEventPublisher(eventMask)
    }
}
