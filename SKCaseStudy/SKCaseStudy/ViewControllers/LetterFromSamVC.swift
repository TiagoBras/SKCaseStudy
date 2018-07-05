//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

class LetterFromSamVC: UIViewController {
    @IBAction func onVisitOutWebsiteButtonPress(_ sender: Any) {
        if let url = URL(string: "https://www.samknows.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
