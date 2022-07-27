# Transitions

## Development Setup

The project should build straight from Xcode without changing anything, but for releases and using fastlane some more dependencies need to be installed:

1. `fastlane` itself: `brew install fastlane`
2. The `release` lane uses a shell script that depends on `create-dmg`. Install this via `brew install create-dmg`