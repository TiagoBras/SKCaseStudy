//
//  BarChartView.swift
//  Designables
//
//  Created by Tiago Bras on 24/04/2018.
//  Copyright © 2018 Tiago Bras. All rights reserved.
//

import UIKit

public struct Spacing: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public typealias FloatLiteralType = Float
    public typealias IntegerLiteralType = Int
    
    public var left: CGFloat = 0
    public var right: CGFloat = 0
    public var top: CGFloat = 0
    public var bottom: CGFloat = 0
    
    public init(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
    
    public init(floatLiteral value: Float) {
        let cgFloat = CGFloat(value)
        
        self.init(left: cgFloat, right: cgFloat, top: cgFloat, bottom: cgFloat)
    }
    
    public init(integerLiteral value: Int) {
        let cgFloat = CGFloat(value)
        
        self.init(left: cgFloat, right: cgFloat, top: cgFloat, bottom: cgFloat)
    }
}

public struct BarChartViewModel {
    public var margin: Spacing = 5
    public var padding: Spacing = Spacing(left: 20, right: 20, top: 8, bottom: 0)
    public var barSpacing: CGFloat = 1
    public var xAxisLabelsPadding: Spacing = 0
    
    public var values: [CGFloat] = []
    public var yAxisSteps = 5
    private(set) var minY: CGFloat = 0
    public var maxY: CGFloat {
        return 1
    }
    
    private var stride: CGFloat {
        guard values.count > 0 else { return 0 }
        
        return 0
    }
    
    public var yAxisLabels: [String] {
        guard values.count > 0 else { return [] }
        
        return []
    }
    
    public var labels: [String] = []
    
    public var showAverage = true
    
    public var boxLineWidth: CGFloat = 1.0
    
    // MARK:- Colors
    public var boxColor = UIColor.black
    public var barColor = UIColor.red
    public var labelsColor = UIColor.black
    public var averageColor = UIColor(red: 0.259, green: 0.616, blue: 0.867, alpha: 1.00)
    
    // MARL:- Font
    public var yAxisLabelsFont: UIFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
    public var xAxisLabelsFont: UIFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
    public var averageLabelFont: UIFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.bold)
    
    // MARK:- Computed properties
    
    public var xLabelsAttributedStrings: [NSAttributedString] {
        let attrs: [NSAttributedStringKey: Any] = [.font: yAxisLabelsFont, .foregroundColor: labelsColor]
        
        return labels.map({ NSAttributedString(string: $0, attributes: attrs) })
    }
    
    public var averageLabelAttributedString: NSAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: averageLabelFont,
                                                   .foregroundColor: averageColor]
        
        return NSAttributedString(string: "Average", attributes: attrs)
    }
    
    public init(values: [CGFloat], labels: [String]) {
        self.values = values
        self.labels = labels
    }
    
    public var yAxisLabelsMaxSize: CGSize {
        let attrs: [NSAttributedStringKey: Any] = [.font: yAxisLabelsFont]
        
        return calculateMaxSize(labels: yAxisLabels, attrs: attrs)
    }
    
    public var xAxisLabelsMaxSize:CGSize {
        let attrs: [NSAttributedStringKey: Any] = [.font: xAxisLabelsFont]
        
        return calculateMaxSize(labels: labels, attrs: attrs)
    }
    
    private func calculateMaxSize(labels: [String], attrs: [NSAttributedStringKey: Any]) -> CGSize {
        var max = CGSize.zero
        
        for label in labels {
            let attrString = NSAttributedString(string: label, attributes: attrs)
            let size = attrString.size()
            
            if size.width > max.width {
                max.width = size.width
            }
            
            if size.height > max.height {
                max.height = size.height
            }
        }
        
        return max
    }
}

@IBDesignable
public class BarChartView: UIView {
    public var viewModel: BarChartViewModel? {
        didSet {
            setNeedsLayout()
        }
    }
    
    public let kBarsAnimationTime: CFTimeInterval = 0.2
    public let kAvgLineAnimationTime: CFTimeInterval = 0.2

    // MARK:- Shapes
    private var _boxFrame: CGRect?
    private var boxFrame: CGRect {
        guard let vm = viewModel else { return .zero }
        
        if _boxFrame == nil {
            let yAxisLabelsSize = vm.yAxisLabelsMaxSize.ceil()
            let xAxisLabelsSize = vm.xAxisLabelsMaxSize.ceil()
            
            let origin = CGPoint(x: yAxisLabelsSize.width + vm.margin.left, y: vm.margin.top)
            let size = CGSize(width: bounds.width - yAxisLabelsSize.width - vm.margin.left - vm.margin.right,
                              height: bounds.height - xAxisLabelsSize.height - vm.margin.bottom - vm.margin.top)
            
            _boxFrame = CGRect(origin: origin, size: size)
        }
        
        return _boxFrame!
    }
    private var boxFrameYZero: CGFloat {
        let boxLineWidth: CGFloat = viewModel?.boxLineWidth ?? 0
        
        return boxFrame.origin.y + boxFrame.height - boxLineWidth
    }
    
    private var _barsFrames: [CGRect]?
    private var barsFrames: [CGRect] {
        guard let vm = viewModel, vm.values.count > 0 else { return [] }
        
        if _barsFrames == nil {
            let barsCount = vm.values.count
            let barWidth = floor((boxFrame.width - vm.padding.left - vm.padding.right -
                vm.barSpacing * CGFloat(barsCount - 1)) / CGFloat(barsCount))
            
            let xOffset = vm.padding.left
            
            _barsFrames = []
            
            guard let maxValue = vm.values.max() else { return _barsFrames! }
            
            let maxHeight = boxFrame.size.height - vm.padding.top
            
            // FIXME: calculate how many pixels it's necessary to represent value Y
            for (i, value) in vm.values.enumerated() {
                let barHeight: CGFloat = maxValue > 0 ? round(value * maxHeight / maxValue) : 0
                let barOrigin = CGPoint(x: xOffset + CGFloat(i) * (barWidth + vm.barSpacing),
                                        y: boxFrameYZero - barHeight + 0.5)
                let barFrame = CGRect(origin: barOrigin,
                                      size: CGSize(width: barWidth, height: barHeight))
                _barsFrames?.append(barFrame)
            }
        }
        
        return _barsFrames!
    }

    private var barsLayers: [CAShapeLayer] {
        guard let vm = viewModel else { return [] }
        
        return barsFrames.map({ (barFrame) -> CAShapeLayer in
            let fromPath = UIBezierPath(rect: CGRect(
                x: barFrame.origin.x,
                y: boxFrame.origin.y + boxFrame.height,
                width: barFrame.width,
                height: 0))
            let toPath = UIBezierPath(rect: barFrame)
            
            let shape = CAShapeLayer()
            shape.fillColor = vm.barColor.cgColor
            shape.path = toPath.cgPath
            
            let anim = CABasicAnimation(keyPath: "path")
            anim.fromValue = fromPath.cgPath
            anim.toValue = toPath.cgPath
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            anim.duration = kBarsAnimationTime
            anim.fillMode = kCAFillModeBackwards
            
            shape.add(anim, forKey: "PATH_ANIMATION")
            
            return shape
        })
    }
    
    private var boxLayer: CAShapeLayer {
        guard let vm = viewModel else { return CAShapeLayer() }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: boxFrame.origin.x,
                              y: boxFrame.origin.y))
        path.addLine(to: CGPoint(x: boxFrame.origin.x,
                                 y: boxFrame.origin.x + boxFrame.size.height))
        path.addLine(to: CGPoint(x: boxFrame.origin.x + boxFrame.size.width - vm.boxLineWidth,
                                 y: boxFrame.origin.x + boxFrame.size.height))
        path.addLine(to: CGPoint(x: boxFrame.origin.x + boxFrame.size.width - vm.boxLineWidth,
                                 y: boxFrame.origin.y))
        
        
        let shape = CAShapeLayer()
        shape.strokeColor = vm.boxColor.cgColor
        shape.fillColor = nil
        shape.path = path.cgPath
        shape.lineWidth = vm.boxLineWidth
        
        return shape
    }
    
    private var averageLineLayer: CAShapeLayer {
        guard let vm = viewModel else { return CAShapeLayer() }
        guard let maxValue = vm.values.max(), maxValue > 0 else { return CAShapeLayer() }
        
        let avg: Double = vm.values.lazy.filter({ $0 > 0 }).reduce(0, { $0 + Double($1) }) / Double(vm.values.count)
        let maxHeight = boxFrame.size.height - vm.padding.top
        let barY = round(CGFloat(avg) * maxHeight / maxValue)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: boxFrame.origin.x, y: barY))
        path.addLine(to: CGPoint(x: boxFrame.origin.x + boxFrame.width - vm.boxLineWidth, y: barY))
        
        let shape = CAShapeLayer()
        shape.fillColor = nil
        shape.strokeColor = vm.averageColor.cgColor
        shape.lineWidth = 1.0
        shape.path = path.cgPath
        shape.frame = layer.bounds
        
        let anim = CABasicAnimation(keyPath: "path")
        anim.fromValue = UIBezierPath(rect: CGRect(x: boxFrame.origin.x, y: barY, width: 0, height: 1)).cgPath
        anim.toValue = path.cgPath
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        anim.duration = kAvgLineAnimationTime
        anim.fillMode = kCAFillModeBackwards
        
        shape.add(anim, forKey: "PATH_ANIMATION")
        
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.string = vm.averageLabelAttributedString
        textLayer.frame = CGRect(x: boxFrame.origin.x + 9.0,
                                 y: barY - 17.0,
                                 width: bounds.width,
                                 height: bounds.height)
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0
        opacityAnim.toValue = 1
        opacityAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        opacityAnim.duration = kAvgLineAnimationTime
        anim.fillMode = kCAFillModeBackwards
        
        textLayer.add(opacityAnim, forKey: "OPACITY_ANIMATION")
        
        shape.addSublayer(textLayer)
        
        return shape
    }
    
    private var _labelsLayers: [CALayer]?
    private var labelsLayers: [CALayer] {
        guard let vm = viewModel, vm.values.count > 0 else { return [] }
        
        if _labelsLayers == nil {
            _labelsLayers = []
            
            if vm.labels.count == vm.values.count {
                for (attrString, barFrame) in zip(vm.xLabelsAttributedStrings, barsFrames) {
                    let alignmentPoint = CGPoint(x: barFrame.midX, y: barFrame.maxY + vm.margin.bottom)
                    let attrStringFrame = CGRect(origin: .zero, size: attrString.size()).aligned(
                        to: alignmentPoint, using: CGRectAligment.topCenter)
                    
                    let textLayer = CATextLayer()
                    textLayer.contentsScale = UIScreen.main.scale
                    textLayer.string = attrString
                    textLayer.frame = attrStringFrame
                    
                    _labelsLayers!.append(textLayer)
                }
            } else {
                let xOffset = boxFrame.origin.x + vm.xAxisLabelsPadding.left
                let stride = (boxFrame.width - vm.padding.left - vm.padding.right) / CGFloat(vm.labels.count)
                
                for (i, attrString) in vm.xLabelsAttributedStrings.enumerated() {
                    let origin = CGPoint(x: xOffset + (stride * CGFloat(i)),
                                         y: boxFrame.size.height + vm.margin.bottom)
                    
                    let textLayer = CATextLayer()
                    textLayer.contentsScale = UIScreen.main.scale
                    textLayer.string = attrString
                    textLayer.frame = CGRect(origin: origin, size: attrString.size())
                    textLayer.alignmentMode = kCAAlignmentCenter
                    
                    _labelsLayers!.append(textLayer)
                }
            }
        }
        
        return _labelsLayers!
    }
    
    // MARK:- Draw methods
    private func drawLabels() {
        guard let vm = viewModel else { return }
        
        // Each label is aligned to its bar
        if vm.labels.count == vm.values.count {
            for (attrString, barFrame) in zip(vm.xLabelsAttributedStrings, barsFrames) {
                let alignmentPoint = CGPoint(x: barFrame.midX, y: barFrame.maxY + vm.margin.bottom)
                let attrStringFrame = CGRect(origin: .zero, size: attrString.size()).aligned(
                    to: alignmentPoint, using: CGRectAligment.topCenter)
                
                attrString.draw(in: attrStringFrame)
            }
        } else {
            let xOffset = boxFrame.origin.x + vm.xAxisLabelsPadding.left
            let stride = (boxFrame.width - vm.padding.left - vm.padding.right) / CGFloat(vm.labels.count)
            
            for (i, attrString) in vm.xLabelsAttributedStrings.enumerated() {
                attrString.draw(at: CGPoint(x: xOffset + (stride * CGFloat(i)),
                                            y: boxFrame.size.height + vm.margin.bottom))
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
        guard let vm = viewModel else { return }
        
        // Delete sublayers (bars shape layers) if they exist
        if let layers = layer.sublayers {
            layers.forEach({ $0.removeFromSuperlayer() })
        }
        
        _boxFrame = nil
        _barsFrames = nil
        _labelsLayers = nil
        
        layer.addSublayer(boxLayer)
        
        for barLayer in barsLayers {
            layer.addSublayer(barLayer)
        }
        
        for textLayer in labelsLayers {
            layer.addSublayer(textLayer)
        }

        if vm.showAverage {
            layer.addSublayer(averageLineLayer)
        }
    }
    
    // MARK:- Interface Builder
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        // For testing purposes
        viewModel = BarChartViewModel(values: [10.4, 12.1, 5.6, 16.9, 3.1, 13.8, 24.2], labels: [])
        viewModel?.labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        viewModel?.xAxisLabelsPadding.left = viewModel!.padding.left
        viewModel?.xAxisLabelsPadding.right = viewModel!.padding.right
        viewModel?.barSpacing = 4.0
        viewModel?.boxColor = UIColor(red: 0.443, green: 0.506, blue: 0.557, alpha: 1.00)
    }
}
