//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

enum ConstraintConstant {
    case top
    case bottom
    case leading
    case trailing
    case all
}

extension UIView {
    class var className: String {
        return String(describing: self)
    }
    
    func pin(to view: UIView, constants: [ConstraintConstant: CGFloat] = [:]) {
        translatesAutoresizingMaskIntoConstraints = false
        
        let allConstant = constants[.all] ?? 0
        
        let topConstant = constants[.top] ?? allConstant
        topAnchor.constraint(equalTo: view.topAnchor, constant: topConstant).isActive = true
        
        let bottomConstant = constants[.bottom] ?? allConstant
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomConstant).isActive = true
        
        let leadingConstant = constants[.leading] ?? allConstant
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingConstant).isActive = true
        
        let trailingConstant = constants[.trailing] ?? allConstant
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingConstant).isActive = true
    }
    
    func addSubviewAndPinToBounds(_ view: UIView, constants: [ConstraintConstant: CGFloat] = [:]) {
        addSubview(view)
        
        view.pin(to: self, constants: constants)
    }
}
