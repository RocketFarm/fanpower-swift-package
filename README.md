# FanpowerPackage

Swift package to display Fanpower widget


# Example Usage

```
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
            propIds: ["25563", "25563"]
        ) {
            self.fanPowerView.isHidden = false
        }
    }
}
```
