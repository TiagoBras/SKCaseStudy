//  Copyright © 2018 Tiago Bras. All rights reserved.
import Foundation

extension Comparable {
    func clamped(min: Self, max: Self) -> Self {
        return self < min ? min : self > max ? max : self
    }
}
