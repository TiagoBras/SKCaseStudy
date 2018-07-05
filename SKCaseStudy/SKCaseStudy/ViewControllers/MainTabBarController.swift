//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor(red: 0.278, green: 0.604, blue: 0.827, alpha: 1.00)
        
        // Create tab view controllers
        viewControllers = TabSpecification.allCases.map { (spec) -> UIViewController in
            let vc = spec.type.init(nibName: spec.type.className, bundle: nil)
            
            spec.extraConfig?(vc)
            
            vc.tabBarItem = UITabBarItem(title: spec.title, image: spec.icon, tag: spec.tag)
            
            let navBar = UINavigationController(rootViewController: vc)
            navBar.navigationBar.isTranslucent = false
            
            return navBar
        }
    }

    // MARK:- Tab View Controllers Specification
    enum TabSpecification {
        case tests, dashboard, results, maps, menu
        
        static let allCases: [TabSpecification] = [.tests, .dashboard, .results, .maps, .menu]
        
        var type: UIViewController.Type {
            switch self {
            case .tests: return TestVC.self
            case .dashboard: return DashboardVC.self
            case .results: return ResultsVC.self
            case .maps: return MapsVC.self
            case .menu: return MenuVC.self
            }
        }
        
        var title: String {
            switch self {
            case .tests: return "Tests"
            case .dashboard: return "Dashboard"
            case .results: return "Results"
            case .maps: return "Maps"
            case .menu: return "Menu"
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .tests: return UIImage(named: "tb_icon_test")
            case .dashboard: return UIImage(named: "tb_icon_dashboard")
            case .results: return UIImage(named: "tb_icon_results")
            case .maps: return UIImage(named: "tb_icon_maps")
            case .menu: return UIImage(named: "tb_icon_menu")
            }
        }
        
        var tag: Int {
            switch self {
            case .tests: return 1
            case .dashboard: return 2
            case .results: return 3
            case .maps: return 4
            case .menu: return 5
            }
        }
        
        var extraConfig: ((UIViewController) -> ())? {
            if self == .results {
                return { vc in
                    guard let vc = vc as? ResultsVC else { return }
                    
                    let specURL = Bundle.main.url(forResource: "results_spec_01", withExtension: "plist")!
                    let spec = try! TestsCountSpecification.fromPList(url: specURL)
                    let dataSources = RandomResultsDataSources(spec: spec).dataSources
                    
                    vc.viewModel = ResultsVCViewModel(dataSources: dataSources)
                }
            } else {
                return nil
            }
        }
    }
}
