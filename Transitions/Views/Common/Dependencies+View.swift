//
//  Dependencies+View.swift
//  Transitions
//
//  Created by Sebastian Wild on 9/20/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import SwiftUI

extension Dependencies {
    struct Dependecy: View {
        let name: String
        let author: String
        let link: URL
        let license: License

        var body: some View {
            VStack(alignment: .leading) {
                Link(label: name, destination: link)
                Text("© \(author)")
            }
        }
    }
}
