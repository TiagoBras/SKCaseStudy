//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

extension UIViewController {
    class var className: String {
        return String(describing: self)
    }
}
