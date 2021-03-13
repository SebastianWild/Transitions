// swift-tools-version:5.2
//
//  Package.swift
//  Transitions
//
//  Created by Sebastian Wild on 3/12/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.43.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.47.12"),
    ]
    // targets: [.target(name: "BuildTools", path: "")]
)
