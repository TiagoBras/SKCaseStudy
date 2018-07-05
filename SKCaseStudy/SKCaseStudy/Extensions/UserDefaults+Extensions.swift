//  Copyright © 2018 Tiago Bras. All rights reserved.
import Foundation

extension UserDefaults {
    struct Keys {
        static let showWelcomeScreen = "showWelcomeScreenKey"
        private init() {}
    }
    
    func shouldInclude(test: TestType) -> Bool {
        return (value(forKey: test.rawValue) as? Bool) ?? true
    }
    
    func setShouldInclude(test: TestType, value: Bool) {
        set(value, forKey: test.rawValue)
    }
    
    var showWelcomeScreen: Bool {
        get {
            return (value(forKey: Keys.showWelcomeScreen) as? Bool) ?? true
        }
        
        set {
            set(newValue, forKey: Keys.showWelcomeScreen)
        }
    }
}
