//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

protocol WelcomeVCDataSource {
    func numberOfPages(_ vc: WelcomeVC) -> Int
    func title(_ vc: WelcomeVC, forPageIndex index: Int) -> String
    func image(_ vc: WelcomeVC, forPageIndex index: Int) -> UIImage?
}

protocol WelcomeVCDelegate {
    func skipButtonPressed(_ vc: WelcomeVC)
}

class WelcomeVC: UIViewController, UIScrollViewDelegate {
    // Since origin/size are not correct until viewDidAppear, I chose to implement this here
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard scrollView.subviews.count == 0 else { return }
        
        for i in 0..<numberOfPages {
            let imageFrame = CGRect(x: scrollView.bounds.width * CGFloat(i),
                                    y: 0,
                                    width: scrollView.bounds.width,
                                    height: scrollView.bounds.height)
            let imageView = UIImageView(frame: imageFrame)
            imageView.contentMode = .center
            imageView.image = datasource?.image(self, forPageIndex: i)
            imageView.tag = i
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(numberOfPages),
                                        height: scrollView.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard numberOfPages > 0 else { return }
        
        scrollView.delegate = self
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        currentIndex = 0
    }
    
    // MARK: Public Fields
    var datasource: WelcomeVCDataSource?
    var delegate: WelcomeVCDelegate?
    
    // Mark: Private Fields & Methods
    private var numberOfPages: Int {
        guard let count = datasource?.numberOfPages(self), count > 0 else {
            log.warning("Number of pages should be greater than 0")
            
            return 0
        }
        
        return count
    }
    
    private var currentIndex = 0 {
        didSet {
            pageControl.currentPage = currentIndex
            
            if let title = datasource?.title(self, forPageIndex: currentIndex) {
                setTitle(title)
            }
        }
    }
    
    private var scrollViewCurrentPage: Int {
        let normalizedOffset = scrollView.contentOffset.x / scrollView.contentSize.width
        
        return Int((normalizedOffset * CGFloat(numberOfPages)).rounded())
    }
    
    private func setTitle(_ title: String) {
        guard titleLabel.text != title else { return }
        
        UIView.animate(withDuration: 0.1, animations: { self.titleLabel.alpha = 0 }) { (_) in
            self.titleLabel.text = title
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [.curveEaseIn],
                       animations: { self.titleLabel.alpha = 1 }, completion: nil)
    }
    
    private func skip() {
        delegate?.skipButtonPressed(self)
    }
    
    // MARK: Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: Actions
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let pageCount = datasource?.numberOfPages(self) else { return }
        
        if currentIndex < pageCount - 1 {
            currentIndex += 1
            
            scrollView.scrollRectToVisible(CGRect(
                x: scrollView.frame.size.width * CGFloat(currentIndex),
                y: 0,
                width: scrollView.frame.size.width,
                height: scrollView.frame.size.height), animated: true)
        } else if currentIndex == pageCount - 1 {
            skip()
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        skip()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = scrollViewCurrentPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageLeftEdgeX = CGFloat(scrollViewCurrentPage) * scrollView.bounds.width
        let pagePosition = scrollView.contentOffset.x - pageLeftEdgeX
        let normalizedPos = pagePosition / scrollView.bounds.width
        
        // Represents how far along the animation it currently is
        let timingProgress: CGFloat = normalizedPos < 0 ? 1.0 + normalizedPos : normalizedPos
        
        let imageOffsetY: CGFloat = 30.0 * sin(4.0 * CGFloat.pi * timingProgress)
        
        scrollView.subviews.forEach { (view) in
            view.transform = CGAffineTransform.init(translationX: 0, y: imageOffsetY)
        }
    }
}

// If this file gets too big, create a separate file for the DataSource and Delegate
// MARK:- DataSource & Delegate Implementation
class WelcomeVCDataSourceDelegate: NSObject, WelcomeVCDataSource, WelcomeVCDelegate {
    private let titles = ["Good internet makes us happy",
                  "Bad internet drives us crazy",
                  "Test your internet with SamKnows"]
    
    private let imageNames: [String]
    private weak var rootVC: RootViewController?
    
    init(rootVC: RootViewController) {
        self.rootVC = rootVC
        imageNames = (1...titles.count).map({ "welcome0\($0)" })
        
        super.init()
    }
    
    // MARK: DataSource
    func numberOfPages(_ vc: WelcomeVC) -> Int {
        return titles.count
    }
    
    func title(_ vc: WelcomeVC, forPageIndex index: Int) -> String {
        return titles[index]
    }
    
    func image(_ vc: WelcomeVC, forPageIndex index: Int) -> UIImage? {
        return UIImage(named: imageNames[index])
    }
    
    // MARK: Delegate
    func skipButtonPressed(_ vc: WelcomeVC) {
        let vc = CellularDataCapVC(nibName: CellularDataCapVC.className, bundle: nil)

        vc.onConfirmation = { [weak self] _ in
            self?.rootVC?.replaceChildViewController(with: MainTabBarController(), animated: true)
        }
 
        rootVC?.replaceChildViewController(with: UINavigationController(rootViewController: vc),
                                           animated: true)
    }
}
