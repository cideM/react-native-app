# iOS Knowledge App

Additional technical documentation can be found in the `_documentation` folder.

## Dependencies

### Git LFS

The project is using [Git LFS](https://git-lfs.github.com), be sure it's installed and set up before trying to run the project:

> brew install git-lfs
> git lfs install
> git lfs pull

### Ruby, Gems and Bundler

We depend on some ruby gems within this project. For best intercompatibility with other projects, this is the recommended way to install the correct version of ruby as well as the gems.

1. Install the [ruby version manager](https://rvm.io) and make sure you can run `rvm help` in the terminal.
2. In the terminal change into the projects root folder and run `rvm current`. It will tell you which version of ruby should be installed and how to install it. After you installed the correct ruby version, run `rvm current` to make sure the correct ruby version is automatically selected.
3. In the terminal run `bundle install`. It will tell you that bundler is not yet installed and will tell you how "to install the missing version" (`gem install bundler:?.?.?`). After that run `bundle install` again to install all required Gems.

Make sure to run fastlane, danger and cocoapods, via bundler with the prefix `bundle exec`, for example `bundle exec fastlane certificates` to make sure you use the correct version.

### Mint Package Manager

We are relying on [Mint Package Manager](https://github.com/yonaskolb/Mint) to manage our developer tooling and make sure we are all on the same version. Please make sure to install `Mint` first.

> brew install mint

All dependencies are listed in the `Mintfile`. To install (or update) all mint dependencies, you can run `mint bootstrap`. If you ever encounter any issue with mint, a possible way to resolve them is to `mint list` all tools installed via mint, delete them (`mint uninstall`) and run `mint bootstrap` again.

### SwiftLint

We use [SwiftLint](https://github.com/realm/SwiftLint) to have a consistent code style. SwiftLint is executed every build on all files changed and not yet committed. To run SwiftLint on all files there is a target `SwiftLint` in the project.

### SwiftGen

We use [SwiftGen](https://github.com/SwiftGen/SwiftGen) to generate types for our localization and image assets. Swiftgen is executed everytime the project is built. If you add a new asset catalogue, make sure to update the `swiftgen.yml` to swift code is generated for it as well.

### Mockolo

We use [Mockolo](https://github.com/uber/mockolo) to autogenerate mocks. 
Mocks are generated whenever Unit tests are performed if `Mockolo` is installed. Mocks should be committed and pushed.

### Sourcery

We use [Sourcery](https://github.com/krzysztofzablocki/Sourcery) to autogenerate fixtures for enums and structs. Fixtures are generated whenever Unit tests are performed if `Sourcery` is installed. Fixtures should be committed and pushed. All templates are defined in the [FixtureFactory](https://github.com/amboss-mededu/ios-fixture-factory) repository.

To autogenerate Fixtures for an initializer, just annotate it with the according sourcery annotation (Note: The trailing column currently is required).

```swift
public struct LearningCardAnchorIdentifier {
    public let xid: String
    
    // sourcery: fixture:
    public init(xid: String) {
        self.xid = xid
    }
}
```

The annotation can contain a default value for every parameter (Note the double quotes around the string).

```swift
public struct LearningCardAnchorIdentifier {
    public let xid: String
    
    // sourcery: fixture: xid=""fixture-xid""
    public init(xid: String) {
        self.xid = xid
    }
}
```

The annotation for an enum can contain a default value as well. Otherwise it will just use a random one.

```swift
// sourcery: fixture: default=.can
public enum LibraryUpdateMode {
    case should
    case must
    case can
}
```

You can also define a default case for a random case. In this example, `SearchResultType.fixture()` will
randomly return `.offline` or `.online` and if it returns `.online` it will actually return `.online(duration: 10.0)`.
```swift
// sourcery: fixture:
enum SearchResultType: Equatable {
    case offline
    // sourcery: fixture:default=".online(duration: 10.0)"
    case online(duration: TimeInterval)
}
```

### CocoaPods

This project uses [CocoaPods](https://cocoapods.org) for all dependencies. All pods are commited.

- We use the '~> 0.1' format to define the version of a pod in the Podfile
- We use the latest available version
- Pods are updated via `bundle exec pod update <podname>`
- To update a pod to a new major version, update the Podfile and perform `bundle exec pod install`
