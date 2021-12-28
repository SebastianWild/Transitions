//
// Created by Sebastian Wild on 8/9/21.
// Copyright (c) 2021 Sebastian Wild. All rights reserved.
//

import Combine

extension Publisher where Failure == Never {
    func assignWeakly<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable {
        sink { [weak object] output in
            object?[keyPath: keyPath] = output
        }
    }
}

extension Publisher {
    func asyncMap<T>(_ transform: @escaping (Output) async -> T) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
}
