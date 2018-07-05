//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

class WhiteBoxVC: UIViewController {
    @IBAction func onSignUpButtonPressed(_ sender: Any) {
        if let url = URL(string: "https://www.samknows.com/products") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
