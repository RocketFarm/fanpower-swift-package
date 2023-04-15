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

---

# Using the `ScrollableFanPowerView`
### Prerequisites
Have a web view with a `ScrollableFanPowerView` placed on top of it.  The `ScrollableFanPowerView` should be constrained to the edges of the web view.
### Example View Controller implementing a `ScrollableFanPowerView`
```swift
import UIKit
import FanpowerPackage
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var fanpowerView: ScrollableFanPowerView!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.loadHTMLString("<div id=\"pu-prop-embed\" class=\\\"pu-prop-embed\\\" data-pickup-prop-id=\\\"25452\\\"><section><a href=\\\"https://playpickup.com/news/Array / surez-vs-chastain-who-wins-in-nashville - 25452\\\" rel=\\\"follow\\\" title=\\\"Suárez vs. Chastain: Who wins in Nashville? - Powered By PickUp\\\">Suárez vs. Chastain: Who wins in Nashville? - Powered By PickUp</a></section></div>", baseURL: nil)
    }
    
    func positionOfElement(withId elementID: String?) {
        let js = "function f(){ var r = document.getElementById('%@').getBoundingClientRect(); return r.top+''; } f();"
        webView?.evaluateJavaScript(String(format: js, elementID!)) { object, error  in
            let stringY = String(describing: object!)
            self.fanpowerView.setup(heightConstant: 750,
                                    topMarginConstant: CGFloat(truncating: NumberFormatter().number(from: stringY)!) 
                                                        * self.webView.scrollView.zoomScale,
                                    bottomMarginConstant: 1500,
                                    tokenForJwtRequest: "your-tokenForJwtRequest",
                                    publisherToken: "your-publisherToken",
                                    publisherId: "your-publisherId",
                                    shareUrl: "your-shareUrl",) {
                self.fanpowerView.isHidden = false
                self.fanpowerView.setCollectionViewLayout()
            }
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fanpowerView.setContentOffset(offset: webView.scrollView.contentOffset)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        positionOfElement(withId: "pu-prop-embed")
    }
}
```
