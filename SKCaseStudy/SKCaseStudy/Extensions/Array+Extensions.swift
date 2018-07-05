//  Copyright © 2018 Tiago Bras. All rights reserved.
import Foundation

extension Array {
    func rotateLeft(times: Int) -> Array {
        let n = times % count
        
        guard count >= 2 && n > 0 else { return self }
        
        return Array(suffix(count - n) + prefix(n))
    }
    
    func rotateRight(times: Int) -> Array {
        return rotateLeft(times: count - times % count)
    }
}
