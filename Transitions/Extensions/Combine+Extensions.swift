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
