//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

protocol ResultsTableViewCellRepresentable {
    var valueText: String { get }
    var valueColor: UIColor { get }
    var icon: UIImage? { get }
    var idText: String { get }
    var dateText: String { get }
}

class ResultsTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setupView(_ data: ResultsTableViewCellRepresentable) {
        amountLabel.text = data.valueText
        amountLabel.textColor = data.valueColor
        iconImageView.image = data.icon
        idLabel.text = data.idText
        dateLabel.text = data.dateText
    }
}
