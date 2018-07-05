//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

extension UITableViewCell {
    class var nib: UINib? {
        return UINib(nibName: className, bundle: nil)
    }
}
