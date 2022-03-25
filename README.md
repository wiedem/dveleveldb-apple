# DVELevelDB Framework for iOS and macOS

DVELevelDB is an open source Swift package for iOS and macOS wrapping the [LevelDB](LevelDB) key-value storage library.

## Using DVELevelDB
To use the framework add the following dependency to your `Package.swift`:
```swift
.package(url: "https://oss.diva-e.com/libraries/dveleveldb-apple", .upToNextMajor(from: "1.0.0")),
```

## Compatibility
DVESecurity is compatible with iOS 12, macOS 11 and requires at least Swift 5.4.
The framework also follows the [SemVer 2.0.0] rules.

[Swift Package Manager]: https://swift.org/package-manager/ "Swift Package Manager"
[LevelDB]: https://github.com/google/leveldb "LevelDB"
[SemVer 2.0.0]: https://semver.org/#semantic-versioning-200 "Semantic Versioning 2.0.0"
