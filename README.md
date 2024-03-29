# FanpowerPackage

Swift package to display Fanpower widget

# Adding the Fanpower Swift Package to your project
### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding the FanPower Swift Package as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/RocketFarm/fanpower-swift-package.git", .exact(version: "0.0.50"))
]
```
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
source 'https://github.com/CocoaPods/Specs.git'

target 'YOUR_TARGET_NAME' do
  pod 'FanpowerPackage', '0.0.49
end
```
Replace YOUR_TARGET_NAME and then, in the Podfile directory, type:

```ruby
$ pod install
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
            propIds: ["00001", "00002"] //Optional parameter, replace with your list of prop IDs.  Can be a list of a single ID.
        ) {
            //self.fanPowerView has completed initialization and is ready to be displayed
            self.fanPowerView.isHidden = false
        }
    }
}
```
`tokenForJwtRequest`, `publisherToken`, and `publisherId` should be supplied to you by FanPower.  `shareUrl` is a URL that users will share when they use the widget's share feature.  It is also used to create the referral URL.  If you do not use the `propIds` parameter, the widget will use all active props from your account.
### Clearing user session (logout)
```swift
import FanpowerPackage

...

FanPower.logout()
```
Most apps will add this to their existing logout flow.
### Adding the Outfit font
After you've added the FanpowerPackage to your project, copy the font file from `Sources/FanpowerPackage/Resources/Fonts/Outfit-VariableFont_wght.ttf` into your project and add the font as described in https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app
### Adding the Stainless font
If your app uses the Stainless font, after you've added the FanpowerPackage to your project, copy the font files from `Sources/FanpowerPackage/Resources/Fonts/Stainless-Black.otf`, `Sources/FanpowerPackage/Resources/Fonts/Stainless-Bold.otf`, and `Sources/FanpowerPackage/Resources/Fonts/Stainless-Regular.otf` into your project and add the font as described in https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app

---

# Using the `ScrollableFanPowerView`
### Prerequisites
Have a web view with a `ScrollableFanPowerView` placed on top of it.  The `ScrollableFanPowerView` should be constrained to the edges of the web view.  The `ScrollableFanPowerView` should have a clear color background.
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
        webView.loadHTMLString("<html><head><meta name='viewport' content='initial-scale=1, user-scalable=no, width=device-width' /></head><body style=\"-webkit-text-size-adjust:none;color:black;\"><p>This weekend, NASCAR&#8217;s premier series returns to Nashville Superspeedway for just the second time.</p><p>The Cup Series heads back to the 1.33-mile concrete oval in Lebanon, Tennessee, for the Ally 400 on Sunday (5 p.m. ET, NBC/NBC Sports App, MRN, SiriusXM NASCAR Radio) after the series&#8217; off weekend.</p>   <div style=\"height:750px;\" id=\"pu-prop-embed\" class=\\\"pu-prop-embed\\\" data-pickup-prop-id=\\\"25452\\\"><section><a href=\\\"https://playpickup.com/news/Array / surez-vs-chastain-who-wins-in-nashville - 25452\\\" rel=\\\"follow\\\" title=\\\"Suárez vs. Chastain: Who wins in Nashville? - Powered By PickUp\\\">Suárez vs. Chastain: Who wins in Nashville? - Powered By PickUp</a></section></div>   <p>[Repeated content] This weekend, NASCAR&#8217;s premier series returns to Nashville Superspeedway for just the second time.</p><p>The Cup Series heads back to the 1.33-mile concrete oval in Lebanon, Tennessee, for the Ally 400 on Sunday (5 p.m. ET, NBC/NBC Sports App, MRN, SiriusXM NASCAR Radio) after the series&#8217; off weekend.</p></body></html>", baseURL: nil)
    }
    
    func positionOfElement(withId elementID: String) {
        let js = "function f(){ var r = document.getElementById('%@').getBoundingClientRect(); return r.top+''; } f();"
        webView?.evaluateJavaScript(String(format: js, elementID)) { object, error  in
            if let object = object {
                let stringY = String(describing: object)
                self.fanpowerView.setup(heightConstant: 750, //This value could be calculated the same way topMarginConstant is
                                        topMarginConstant: CGFloat(truncating: NumberFormatter().number(from: stringY)!) 
                                                            * self.webView.scrollView.zoomScale,
                                        bottomMarginConstant: 1500, //This value could be calculated the same way topMarginConstant is
                                        tokenForJwtRequest: "your-tokenForJwtRequest",
                                        publisherToken: "your-publisherToken",
                                        publisherId: "your-publisherId",
                                        shareUrl: "your-shareUrl",
                                        referenceFrame: self.webView.frame, //Passing nil for this param will make the scrollview full-screen
                                        propIds: ["00001", "00002"] ) {  //Optional parameter, replace with your list of prop IDs.  Can be a list of a single ID.
                    self.fanpowerView.isHidden = false
                    self.fanpowerView.setCollectionViewLayout() //This line allows the widget to update its UI layout after it has been moved
                }
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

---

# Using the `ScrollableFanPowerView` when using HTML with an embedded Tweet
### Prerequisites
Have a web view with a `ScrollableFanPowerView` placed on top of it.  The `ScrollableFanPowerView` should be constrained to the edges of the web view.  The `ScrollableFanPowerView` should have a clear color background.  The web view's HTML will include an embedded Tweet.
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
        //navigation delegate is not needed for this implementation
        let tweet = "<blockquote id=\"tweet\" class=\"twitter-tweet\"><p lang=\"en\" dir=\"ltr\">Sunsets don&#39;t get much better than this one over <a href=\"https://twitter.com/GrandTetonNPS?ref_src=twsrc%5Etfw\">@GrandTetonNPS</a>. <a href=\"https://twitter.com/hashtag/nature?src=hash&amp;ref_src=twsrc%5Etfw\">#nature</a> <a href=\"https://twitter.com/hashtag/sunset?src=hash&amp;ref_src=twsrc%5Etfw\">#sunset</a> <a href=\"http://t.co/YuKy2rcjyU\">pic.twitter.com/YuKy2rcjyU</a></p>&mdash; US Department of the Interior (@Interior) <a href=\"https://twitter.com/Interior/status/463440424141459456?ref_src=twsrc%5Etfw\">May 5, 2014</a></blockquote> <script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>"
        webView.loadHTMLString("<html><head><meta name='viewport' content='initial-scale=1, user-scalable=no, width=device-width' /></head><body style=\"-webkit-text-size-adjust:none;color:black;\">"+tweet+"<p>This weekend, NASCAR&#8217;s premier series returns to Nashville Superspeedway for just the second time.</p><p>The Cup Series heads back to the 1.33-mile concrete oval in Lebanon, Tennessee, for the Ally 400 on Sunday (5 p.m. ET, NBC/NBC Sports App, MRN, SiriusXM NASCAR Radio) after the series&#8217; off weekend.</p>   <div style=\"height:750px;\" id=\"pu-prop-embed\" class=\\\"pu-prop-embed\\\" data-pickup-prop-id=\\\"25452\\\"><section><a href=\\\"https://playpickup.com/news/Array / surez-vs-chastain-who-wins-in-nashville - 25452\\\" rel=\\\"follow\\\" title=\\\"Suárez vs. Chastain: Who wins in Nashville? - Powered By PickUp\\\">Suárez vs. Chastain: Who wins in Nashville? - Powered By PickUp</a></section></div>   <p>[Repeated content] This weekend, NASCAR&#8217;s premier series returns to Nashville Superspeedway for just the second time.</p><p>The Cup Series heads back to the 1.33-mile concrete oval in Lebanon, Tennessee, for the Ally 400 on Sunday (5 p.m. ET, NBC/NBC Sports App, MRN, SiriusXM NASCAR Radio) after the series&#8217; off weekend.</p></body></html>", baseURL: nil)

        twitterHeightTest()
    }
    
    func twitterHeightTest() {
        var isTallEnough = false
        let tooShortHeight = 10 //value to be determined by the developer
        let heightTestInterval = 0.5 //code checks for twitter load every 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + heightTestInterval) { [weak self] in
            let js = "function f(){ var r = document.getElementsByClassName('%@')[0].getBoundingClientRect(); return r.height+''; } f();"
            self?.webView?.evaluateJavaScript(String(format: js, "twitter-tweet")) { object, error  in
                if let object = object {
                    let stringY = String(describing: object)
                    print("tweet height is \(stringY)")
                    let intHeight = Int(stringY) ?? 0
                    if intHeight > tooShortHeight {
                        isTallEnough = true
                    }
                }
                if !isTallEnough {
                    self?.twitterHeightTest() //repeat the test until it succeeds or the nav controller is deallocated
                } else {
                    self?.positionOfElement(withId: "pu-prop-embed")
                }
            }
        }
    }
    
    func positionOfElement(withId elementID: String) {
        let js = "function f(){ var r = document.getElementById('%@').getBoundingClientRect(); return r.top+''; } f();"
        webView?.evaluateJavaScript(String(format: js, elementID)) { object, error  in
            if let object = object {
                let stringY = String(describing: object)
                self.fanpowerView.setup(heightConstant: 750, //This value could be calculated the same way topMarginConstant is
                                        topMarginConstant: CGFloat(truncating: NumberFormatter().number(from: stringY)!) 
                                                            * self.webView.scrollView.zoomScale,
                                        bottomMarginConstant: 1500, //This value could be calculated the same way topMarginConstant is
                                        tokenForJwtRequest: "your-tokenForJwtRequest",
                                        publisherToken: "your-publisherToken",
                                        publisherId: "your-publisherId",
                                        shareUrl: "your-shareUrl",
                                        referenceFrame: self.webView.frame, //Passing nil for this param will make the scrollview full-screen
                                        propIds: ["00001", "00002"] ) {  //Optional parameter, replace with your list of prop IDs.  Can be a list of a single ID.
                    self.fanpowerView.isHidden = false
                    self.fanpowerView.setCollectionViewLayout() //This line allows the widget to update its UI layout after it has been moved
                }
            }
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fanpowerView.setContentOffset(offset: webView.scrollView.contentOffset)
    }
}
```
