//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

let log: Logger = {
    let configuration = Logger.Configuration(
        showTimestamp: false,
        showFileName: true,
        showFunctionName: false,
        showLineNumber: true)
    
    return Logger(level: .info, configuration: configuration)
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var rootVC = RootViewController()
    
    private lazy var welcomeVC: WelcomeVC = {
        let vc = WelcomeVC(nibName: WelcomeVC.className, bundle: nil)
        let dataSourceDelegate = WelcomeVCDataSourceDelegate(rootVC: self.rootVC)
        vc.delegate = dataSourceDelegate
        vc.datasource = dataSourceDelegate
        
        return vc
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Comment the following line to revert to standard behavior
        UserDefaults.standard.showWelcomeScreen = false
        
        if  UserDefaults.standard.showWelcomeScreen {
            let welcome = UINavigationController(rootViewController: welcomeVC)
            
            rootVC.replaceChildViewController(with: welcome)
        } else {
            rootVC.replaceChildViewController(with: MainTabBarController())
        }  
        
        
//        let specURL = Bundle.main.url(forResource: "results_spec_01", withExtension: "plist")!
//        let spec = try! TestsCountSpecification.fromPList(url: specURL)
//        let results = ResultsContentVC(nibName: ResultsContentVC.className, bundle: nil)
////        let db = RandomResultsDataSources(spec: spec)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            results.dataSource = RandomResultsDataSources(spec: spec).downloadTestsDataSource
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            results.dataSource = RandomResultsDataSources(spec: spec).downloadTestsDataSource
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            results.dataSource = RandomResultsDataSources(spec: spec).downloadTestsDataSource
//        }
        
//        rootVC.replaceChildViewController(with: UINavigationController(rootViewController: mainTabBar))
        
        window = UIWindow()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = Color.mainColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

