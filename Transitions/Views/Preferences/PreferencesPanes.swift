//
//  PreferencesPane.swift
//  Transitions
//
//  Created by Sebastian Wild on 8/14/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation
import Preferences
import SwiftUI

// swiftlint:disable line_length
/*
 Here I rely heavily on Sidre Sorhus's great Preferences UI library, whose MIT license is pasted below and also visible in Transition's settings:

 MIT License

 Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (sindresorhus.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
// swiftlint:enable line_length

enum PreferencePanes {
    static let contentWidth: Double = 450.0

    static func buildController(with userData: UserData = .main, and controller: DisplaysController = .main) -> PreferencesWindowController {
        PreferencesWindowController(
            panes: [
                Preferences.Pane(
                    identifier: Preferences.PaneIdentifier("general"),
                    title: "general".localized,
                    toolbarIcon: .gear
                ) {
                    General()
                        .environmentObject(userData)
                        .environmentObject(controller)
                },
                Preferences.Pane(
                    identifier: Preferences.PaneIdentifier("about"),
                    title: "about".localized,
                    toolbarIcon: .info_circle
                ) {
                    About()
                        .environmentObject(userData)
                        .environmentObject(controller)
                }
            ]
        )
    }
}

extension PreferencePanes {
    struct General: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        var body: some View {
            Preferences.Container(contentWidth: PreferencePanes.contentWidth) {
                Preferences.Section(title: "general".localized) {
                    Toggle(isOn: $userData.isAppEnabled) {
                        Text(LocalizedStringKey.Preferences.enabled)
                    }
                    Toggle(isOn: $controller.isStartingOnLogon) {
                        Text(LocalizedStringKey.Preferences.start_on_logon)
                    }
                }
            }
        }
    }
}

extension PreferencePanes {
    struct About: View {
        @EnvironmentObject private var userData: UserData
        @EnvironmentObject private var controller: DisplaysController

        @State private var mitTextExpanded: Bool = false

        var body: some View {
            Preferences.Container(contentWidth: PreferencePanes.contentWidth) {
                Preferences.Section(title: "") {
                    VStack(alignment: .leading, spacing: 5.0) {
                        Text(Bundle.main.displayName)
                            .bold()
                            .font(.largeTitle)
                        Text("\("version".localized): \(Bundle.main.shortVersionString)")
                            .bold()
                        Text("© \("author".localized)")
                        Text(LocalizedStringKey.Preferences.about_description)
                    }

                    Divider()

                    HStack {
                        Text("Libraries under MIT license")
                            .bold()
                        Toggle("􀐸", isOn: $mitTextExpanded)
                            .toggleStyle(ToggleButtonStyle())
                    }

                    if mitTextExpanded {
                        Text(License.MIT.text)
                            .font(.subheadline)
                            .lineLimit(nil)
                            // Needed to fix weird expansion issues with text.
                            // Without this the text upon expansion does not go beyond one line
                            // https://stackoverflow.com/a/58335789
                            .fixedSize(horizontal: false, vertical: true)
                            .padding([.bottom], 5.0)
                        // TODO: Smooth animation when expanding!
                    }

                    HStack {
                        ForEach(Dependencies.allCases.indices) {
                            Dependencies.allCases[$0].description
                        }
                    }
                }
            }
        }
    }
}

struct PreferencePanes_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferencePanes.General()
                .environmentObject(UserData())
                .environmentObject(DisplaysController(userData: UserData()))
                .previewDisplayName("General")
            PreferencePanes.About()
                .environmentObject(UserData())
                .environmentObject(DisplaysController(userData: UserData()))
                .previewDisplayName("About")
        }
    }
}

struct ToggleButtonStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }, label: {
            configuration.label
        })
            .buttonStyle(ButtonToggleStyle(highlighted: configuration.isOn))
    }
}

struct ButtonToggleStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    let highlighted: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.leading, .trailing], 8.0)
            .padding([.top, .bottom], 2.0)
            .foregroundColor(foregroundColor(configuration))
            .background(
                RoundedRectangle(cornerRadius: 5.0)
                    .strokeBorder(colorScheme == .dark ? Color.gray : Color.gray, lineWidth: 0.5)
                    .background(
                        RoundedRectangle(cornerRadius: 5.0)
                            .fill(fillColor(configuration))
                    )
            )
    }

    private func foregroundColor(_ configuration: Configuration) -> Color {
        var light: Color {
            configuration.isPressed || highlighted ? .white : .primary
        }

        var dark: Color {
            configuration.isPressed ? .white : .primary
        }

        switch colorScheme {
        case .light:
            return light
        case .dark:
            return dark
        @unknown default:
            return light
        }
    }

    private func fillColor(_ configuration: Configuration) -> Color {
        var light: Color {
            configuration.isPressed || highlighted ? .accentColor : .white
        }

        var dark: Color {
            configuration.isPressed || highlighted ? .accentColor : .secondary
        }

        switch colorScheme {
        case .light:
            return light
        case .dark:
            return dark
        @unknown default:
            return light
        }
    }
}

enum Dependencies: CaseIterable {
    case preferences
    case sliders

    var description: Dependecy {
        switch self {
        case .preferences:
            return Dependecy(
                name: "swiftui-sliders",
                author: "SpaceNation Inc.",
                // swiftlint:disable:next force_unwrapping
                link: URL(string: "https://github.com/spacenation/swiftui-sliders")!,
                license: .MIT
            )
        case .sliders:
            return Dependecy(
                name: "Preferences",
                author: "Sindre Sorhus",
                // swiftlint:disable:next force_unwrapping
                link: URL(string: "https://github.com/sindresorhus/Preferences")!,
                license: .MIT
            )
        }
    }
}

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

/// Standard SwiftUI `Link` is only on macOS 11 or newer - this is a rough (but less flexible) equivalent
struct Link: View {
    let label: String
    let destination: URL

    @State private var isHovering: Bool = false
    private let linkColor = Color.accentColor

    var body: some View {
        Text(label)
            .bold()
            .underline(isHovering, color: linkColor)
            .foregroundColor(linkColor)
            .onHover(perform: { hovering in
                isHovering = hovering
            })
            .onTapGesture {
                NSWorkspace.shared.open(destination)
            }
    }
}

enum License {
    case MIT

    var text: String {
        switch self {
        case .MIT:
            return
                """
                Permission Is hereby granted, free of charge, to any person obtaining a copy of this software and assoclated documentation
                files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,
                merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software Is
                furnished to do so, subject to the following conditions:

                The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

                THE SOFTWARE IS PROVIDED *AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
                LIMITED TO 1 WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
                NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
                SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                """
        }
    }
}
