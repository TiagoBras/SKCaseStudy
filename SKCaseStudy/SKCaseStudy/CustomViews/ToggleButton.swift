//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

class ToggleButton: UIButton {
    private override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("not implemented: use init(offImage:, onImage:)")
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("not implemented: use init(offImage:, onImage:)")
    }

    init(offImage: UIImage?, onImage: UIImage?) {
        if offImage?.size != onImage?.size {
            log.warning("onImage and offImage are not of the same size")
        }
        
        let size = offImage?.size ?? onImage?.size ?? CGSize.zero
        
        super.init(frame: CGRect(origin: .zero, size: size))
        
        setImage(offImage, for: .normal)
        setImage(onImage, for: .selected)
        
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    @objc func touchUpInside() {
        isSelected = !isSelected
        
        sendActions(for: .valueChanged)
    }
}
