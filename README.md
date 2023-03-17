# FanpowerPackage

Swift package to display Fanpower widget

# Adding the Fanpower Swift Package to your project
### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding the FanPower Swift Package as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/RocketFarm/fanpower-swift-package.git", .exact(version: "0.0.26"))
]
```
# Example Usage
### Initializing the widget
```swift
import UIKit
import FanpowerPackage

class ViewController: UIViewController {
    @IBOutlet weak var fanPowerView: FanPowerView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fanPowerView.setup(
            tokenForJwtRequest: "your-tokenForJwtRequest",
            publisherToken: "your-publisherToken",
            publisherId: "your-publisherId",
            shareUrl: "your-shareUrl",
            propIds: ["00001", "00002"] //replace with your list of prop IDs.  Can be a list of a single ID.
        ) {
            //self.fanPowerView has completed initialization and is ready to be displayed
            self.fanPowerView.isHidden = false
        }
    }
}
```
`tokenForJwtRequest`, `publisherToken`, and `publisherId` should be supplied to you by FanPower.  `shareUrl` is a URL that users will share when they use the widget's share feature.  It is also used to create the referral URL.
### Clearing user session (logout)
```swift
import FanpowerPackage

...

FanPower.logout()
```
Most apps will add this to their existing logout flow.
