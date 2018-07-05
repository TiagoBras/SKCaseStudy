//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

class ClassicTableViewCell: UITableViewCell {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    var associatedValue: Any?
}
