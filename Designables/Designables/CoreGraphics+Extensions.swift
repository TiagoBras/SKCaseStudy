//  Copyright © 2018 Tiago Bras. All rights reserved.
import CoreGraphics

extension CGPoint {
    func round() -> CGPoint {
        return CGPoint(x: x.rounded(), y: y.rounded())
    }
    
    func floor() -> CGPoint {
        return CGPoint(x: Darwin.floor(x), y: Darwin.floor(y))
    }
    
    func ceil() -> CGPoint {
        return CGPoint(x: Darwin.ceil(x), y: Darwin.ceil(y))
    }
}

extension CGSize {
    func round() -> CGSize {
        return CGSize(width: width.rounded(), height: height.rounded())
    }
    
    func floor() -> CGSize {
        return CGSize(width: Darwin.floor(width), height: Darwin.floor(height))
    }
    
    func ceil() -> CGSize {
        return CGSize(width: Darwin.ceil(width), height: Darwin.ceil(height))
    }
}

enum CGRectAligment {
    case topLeft, topCenter, topRight
    case centerLeft, center, centerRight
    case bottomLeft, bottomCenter, bottomRight
}

extension CGRect {
    func round() -> CGRect {
        return CGRect(origin: origin.round(), size: size.round())
    }
    
    func floor() -> CGRect {
        return CGRect(origin: origin.floor(), size: size.floor())
    }
    
    func ceil() -> CGRect {
        return CGRect(origin: origin.ceil(), size: size.ceil())
    }
    
    mutating func align(to point: CGPoint, using alignment: CGRectAligment) {
        switch alignment {
        case .topLeft:
            origin.x = point.x
            origin.y = point.y
        case .topCenter:
            origin.x = point.x - width * 0.5
            origin.y = point.y
        case .topRight:
            origin.x = point.x - width
            origin.y = point.y
        case .centerLeft:
            origin.x = point.x
            origin.y = point.y - height * 0.5
        case .center:
            origin.x = point.x - width * 0.5
            origin.y = point.y - height * 0.5
        case .centerRight:
            origin.x = point.x - width
            origin.y = point.y - height * 0.5
        case .bottomLeft:
            origin.x = point.x
            origin.y = point.y - height
        case .bottomCenter:
            origin.x = point.x - width * 0.5
            origin.y = point.y - height
        case .bottomRight:
            origin.x = point.x - width
            origin.y = point.y - height
        }
    }
    
    func aligned(to point: CGPoint, using alignment: CGRectAligment) -> CGRect {
        var copy = self
        copy.align(to: point, using: alignment)
        
        return copy
    }
}

