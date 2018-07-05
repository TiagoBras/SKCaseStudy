//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

class RootViewController: UIViewController {
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func replaceChildViewController(with vc: UIViewController, animated: Bool = false) {
        vc.view.frame = view.frame
        
        guard let oldChild = childViewControllers.first else {
            addChildViewController(vc)
            view.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
            
            return
        }
        
        oldChild.willMove(toParentViewController: nil)
        
        addChildViewController(vc)
        
        if animated {
            oldChild.view.alpha = 1
            vc.view.alpha = 0
            
            transition(
                from: oldChild,
                to: vc,
                duration: 0.5,
                options: [],
                animations: {
                    vc.view.alpha = 1
                    oldChild.view.alpha = 0
            }) { _ in
                oldChild.view.removeFromSuperview()
                oldChild.removeFromParentViewController()
                vc.didMove(toParentViewController: self)
            }
        } else {
            oldChild.view.removeFromSuperview()
            oldChild.removeFromParentViewController()
            view.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
        }
    }
}
