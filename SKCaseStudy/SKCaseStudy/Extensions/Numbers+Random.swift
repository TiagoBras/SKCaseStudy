//  Copyright © 2018 Tiago Bras. All rights reserved.
import Foundation

extension UInt32 {
    static func random(min: UInt32, max: UInt32) -> UInt32 {
        return arc4random_uniform(max - min + 1) + min
    }
}

extension Double {
    static func random(min: Double, max: Double) -> Double {
        return Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max) * (max - min) + min
    }
    
    func string(desiredDigitsCount: Int) -> String {
        let components = String(describing: self).components(separatedBy: ".")
        
        guard components.count <= 2 else {
            return "\(self)"
        }
        
        let integerPart = components.first!
        if integerPart.count >= desiredDigitsCount {
            return "\(integerPart)"
        }
        
        var fractionalPart = ""
        if components.count == 2 {
            fractionalPart += components[1].prefix(desiredDigitsCount - integerPart.count)
        }
        
        let missingDigitsCount = desiredDigitsCount - integerPart.count - fractionalPart.count
        
        if missingDigitsCount > 0 {
            fractionalPart += String(repeating: "0", count: missingDigitsCount)
        }
        
        return "\(integerPart).\(fractionalPart)"
    }
}

