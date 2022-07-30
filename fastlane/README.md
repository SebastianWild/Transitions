fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Mac

### mac setup

```sh
[bundle exec] fastlane mac setup
```

setup lane. Configure environment variables, check if running on CI, etc.

### mac test

```sh
[bundle exec] fastlane mac test
```

run tests

### mac development

```sh
[bundle exec] fastlane mac development
```

archive the app, but do not create a DMG

### mac release

```sh
[bundle exec] fastlane mac release
```

archive the app, notarize, and create a DMG

### mac bumpversion

```sh
[bundle exec] fastlane mac bumpversion
```

Bump the version number

### mac bumpbuild

```sh
[bundle exec] fastlane mac bumpbuild
```

Bump the build number

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
