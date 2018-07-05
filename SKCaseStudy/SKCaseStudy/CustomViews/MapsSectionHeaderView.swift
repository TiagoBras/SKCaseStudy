//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

public class MapsSectionHeaderView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        Bundle(for: MapsSectionHeaderView.self).loadNibNamed(
            String(describing: type(of: self)), owner: self, options: nil)
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    // MARK:- Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ssidLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}
