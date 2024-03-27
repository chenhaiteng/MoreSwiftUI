# MoreSwiftUI
A collection of custom swiftUI controls
[![Version](https://img.shields.io/cocoapods/v/MoreSwiftUI.svg?style=flat)](https://cocoapods.org/pods/MoreSwiftUI)
[![License](https://img.shields.io/cocoapods/l/MoreSwiftUI.svg?style=flat)](https://cocoapods.org/pods/MoreSwiftUI)
[![Platform](https://img.shields.io/cocoapods/p/MoreSwiftUI.svg?style=flat)](https://cocoapods.org/pods/MoreSwiftUI)

## Requirements

## Installation

### Swift Package Manager
#### - Add to Xcode(To use this package in your application):

1. File > Swift Packages > Add Package Dependency...
2. Choose Project you want to add MoreSwiftUI
3. Paste repository https://github.com/chenhaiteng/MoreSwiftUI.git
4. Rules > Version: Up to Next Major 0.1.0
It's can also apply Rules > Branch : main to access latest code.
If you want try some experimental features, you can also apply Rules > Branch : develop

**Note:** It might need to link MoreSwiftUI to your target maunally.
1. Open *Project Editor* by tap on root of project navigator
2. Choose the target you want to use MoreSwiftUI.
3. Choose **Build Phases**, and expand **Link Binary With Libraries**
4. Tap on **+** button, and choose MoreSwiftUI to add it.

#### - Add to SPM package(To use this package in your library/framework):
```swift
dependencies: [
    .package(url: "https://github.com/chenhaiteng/MoreSwiftUI.git", from: "0.4.0")
    // To specify branch, use following statement to instead of.
    // .package(url: "https://github.com/chenhaiteng/MoreSwiftUI.git", branch: "${branch_name}"))
],
targets: [
    .target(
        name: "MyPackage",
        dependencies: ["MoreSwiftUI"]),
]
```

### CocoaPods
MoreSwiftUI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MoreSwiftUI'
```

## License

MoreSwiftUI is available under the MIT license. See the LICENSE file for more info.
