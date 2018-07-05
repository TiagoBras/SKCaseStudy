//  Copyright © 2018 Tiago Bras. All rights reserved.
import Foundation

class MathHelper {
    static func clamp<V: Comparable>(value: V, min: V, max: V) -> V {
        if value < min {
            return min
        }
        
        if value > max {
            return max
        }
        
        return value
    }
}
