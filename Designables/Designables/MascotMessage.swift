//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

// FIXME: uncommenting IBDesignable causes "Failed to render and update auto layourt status
@IBDesignable
public class MascotMessage: UIView {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    @IBInspectable var text: String = "Label" {
        didSet {
            textLabel.text = text
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        Bundle(for: MascotMessage.self).loadNibNamed(
            String(describing: type(of: self)), owner: self, options: nil)
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    public class func newFromNib() -> MascotMessage {
        return MascotMessage(frame: .zero)
    }
}
