//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

public protocol TabHeadersViewDelegate {
    func tabSelected(_ view: TabHeadersView, previousIndex: Int, currentIndex: Int)
}

@IBDesignable
public class TabHeadersView: UIView, UIScrollViewDelegate {
    private let padding: CGFloat = 16
    private let indicatorPadding: CGFloat = -4
    private let tabSpacing: CGFloat = 18
    
    public var delegate: TabHeadersViewDelegate?
    
    private lazy var tabIndicatorLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.frame = CGRect(x: 0, y: bounds.origin.y + bounds.height - tabIndicatorHeight,
                             width: 1, height: tabIndicatorHeight)
        shape.backgroundColor = tabIndicatorColor.cgColor
        shape.contentsScale = UIScreen.main.scale

        return shape
    }()
    
    @IBInspectable
    public var font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular) { didSet { setNeedsLayout() }}
    @IBInspectable
    public var textColor: UIColor = UIColor.darkGray {
        didSet {
            for tab in tabs {
                tab.textColor = textColor
            }
            setNeedsLayout()
        }
    }
    @IBInspectable
    public var selectedTextColor: UIColor = UIColor.black {
        didSet {
            for tab in tabs {
                tab.selectedTextColor = textColor
            }
            setNeedsLayout()
        }
    }
    @IBInspectable
    public var tabIndicatorHeight: CGFloat = 4 { didSet { setNeedsLayout() }}
    @IBInspectable
    public var tabIndicatorColor: UIColor = UIColor(red: 0.259, green: 0.616, blue: 0.867, alpha: 1.00)
    
    public var selectedTab: Int = 0 {
        didSet {
            for (n, tab) in tabs.enumerated() {
                tab.isSelected = n == selectedTab
            }
            
            guard selectedTab >= 0 && selectedTab < tabs.count else { return }

            let translate = CGAffineTransform(translationX: tabs[selectedTab].frame.midX, y: 0)
            let tabWidth = tabs[selectedTab].bounds.width - indicatorPadding * 2

            tabIndicatorLayer.transform = CATransform3DMakeAffineTransform(translate.scaledBy(x: tabWidth, y: 1))
            
            scrollToXCenteredInScrollView(x: tabs[selectedTab].frame.midX, animated: true)
        }
    }
    
    @objc func tabTouchUpInside(_ sender: Tab) {
        delegate?.tabSelected(self, previousIndex: selectedTab, currentIndex: sender.tag)
        
        selectedTab = sender.tag
        setNeedsDisplay()
    }
    
    public var tabSpecs: [TabSpec] = [] {
        didSet {
            tabs.forEach({ $0.removeTarget(nil, action: nil, for: .allEvents) })
            tabs = []
            scrollView.subviews.forEach({ $0.removeFromSuperview() })
            
            for (i, spec) in tabSpecs.enumerated() {
                let tab = Tab(frame: .zero)
                tab.text = spec.name
                tab.icon = spec.icon
                tab.font = font
                tab.textColor = textColor
                tab.selectedTextColor = selectedTextColor
                tab.tag = i
                tab.addTarget(self, action: #selector(tabTouchUpInside(_:)), for: .touchUpInside)
                tab.sizeToFit()

                tabs.append(tab)
                scrollView.addSubview(tab)
            }
            
            layoutIfNeeded()
            selectedTab = 0
        }
    }
    private var tabs: [Tab] = []
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.delegate = self
        sv.showsHorizontalScrollIndicator = false
        sv.delaysContentTouches = true
        
        return sv
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        scrollView.layer.addSublayer(tabIndicatorLayer)
        
        selectedTab = 0
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard tabs.count > 0 else { return }
        
        let totalPadding = padding * 2
        let totalSpacing = (CGFloat(tabs.count) - 1) * tabSpacing
        
        tabs.forEach({ $0.sizeToFit() })
        
        // Calculate how much space all tabs take
        let totalWidth = tabs.reduce(0, { $0 + $1.bounds.width })
        
        // If there is only one tab, make it the same size as its parent view
        guard tabs.count > 1 else {
            tabs.first!.frame.origin = CGPoint(x: padding, y: 0)
            tabs.first!.frame.size = CGSize(width: bounds.width - totalPadding, height: bounds.height)
            tabs.first!.setNeedsLayout()
            
            return
        }
        
        let neededWidth = totalWidth + totalPadding + totalSpacing
        if neededWidth < bounds.width {
            guard let widestTabWidth = tabs.max(by: { $0.bounds.width < $1.bounds.height }) else { return }
            
            print(widestTabWidth)
            let desiredWidth = round((bounds.width - totalPadding - totalSpacing) / CGFloat(tabs.count))
            print(desiredWidth)
            if widestTabWidth.bounds.width <= desiredWidth {
                for i in 0..<tabs.count {
                    tabs[i].frame.origin.x = padding + (desiredWidth + tabSpacing) * CGFloat(i)
                    tabs[i].frame.size = CGSize(width: desiredWidth, height: bounds.height)
                    tabs[i].setNeedsLayout()
                }
            } else {
                let extraWidth = round(bounds.width - neededWidth) / CGFloat(tabs.count - 1)
                
                var xOffset = padding
                for tab in tabs {
                    tab.frame.origin.x = xOffset
                    
                    if tab != widestTabWidth {
                        xOffset += tab.frame.size.width + tabSpacing + extraWidth
                        tab.frame.size = CGSize(width: tab.frame.size.width + extraWidth, height: bounds.height)
                    } else {
                        xOffset += tab.frame.size.width + tabSpacing
                        tab.frame.size = CGSize(width: tab.frame.size.width, height: bounds.height)
                    }
                    tab.setNeedsLayout()
                }
            }
            
            scrollView.contentSize = bounds.size
        } else {
            var xOffset = padding
            for tab in tabs {
                tab.frame.origin.x = xOffset
                tab.frame.size = CGSize(width: tab.frame.size.width, height: bounds.height)
                tab.setNeedsLayout()
                
                xOffset += tab.frame.size.width + tabSpacing
            }
            
            scrollView.contentSize = CGSize(width: neededWidth, height: bounds.height)
        }
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        tabSpecs = [
            TabSpec(name: "Downloads"),
            TabSpec(name: "Uploads")
        ]
    }
    
    public struct TabSpec {
        public var icon: UIImage?
        public var name: String
        
        public init(name: String, icon: UIImage? = nil) {
            self.name = name
            self.icon = icon
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Hack: views inside a scroll view controller not always receive touchEnd events
        for tab in tabs {
            tab.contentLayer.opacity = 1.0
        }
    }
    
    private func scrollToXCenteredInScrollView(x: CGFloat, animated: Bool) {
        let halfWidth = scrollView.bounds.width / 2
        let contentXOffset = (x - halfWidth).clamped(min: 0, max: scrollView.contentSize.width - halfWidth)
        
        scrollView.scrollRectToVisible(CGRect(x: contentXOffset,
                                              y: 0,
                                              width: scrollView.bounds.width,
                                              height: scrollView.bounds.height), animated: animated)
    }
    
    public var tabIndicatorNormalizedOffsetX: CGFloat? {
        didSet {
            if let xOffset = tabIndicatorNormalizedOffsetX {
                // Normalized to range: [0, tabs.count)
                var p = CGFloat(tabs.count) * xOffset
                let prevPage = Int(p)
                
                guard prevPage >= 0 && tabs.count > prevPage + 1 else { return }
                
                // Normalize it to range: [0, 1]
                p -= CGFloat(prevPage)
                
                let currWidth = tabs[prevPage].bounds.width
                let nextWidth = tabs[prevPage+1].bounds.width
                
                // Interpolate width within range [prevWidth, nextWidth]
                let interpolatedWidth = (nextWidth - currWidth) * p + currWidth
                
                let prevMidX = tabs[prevPage].frame.midX
                let nextMidX = tabs[prevPage+1].frame.midX
                
                let xOffset = (nextMidX - prevMidX) * p + prevMidX
                
                scrollToXCenteredInScrollView(x: xOffset, animated: false)
                
                let scale = CGAffineTransform(scaleX: interpolatedWidth - indicatorPadding * 2, y: 1)
                let trans = CGAffineTransform(translationX: xOffset, y: 0)
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                tabIndicatorLayer.transform = CATransform3DMakeAffineTransform(scale.concatenating(trans))
                CATransaction.commit()
            }
        }
    }
}

class Tab: UIControl {
//    private let padding: CGFloat = 4
    private let iconTextSpacing: CGFloat = 10
    
    var textColor: UIColor = UIColor.black { didSet { refreshLayout() }}
    var selectedTextColor: UIColor = UIColor.darkGray { didSet { refreshLayout() }}
    var font: UIFont = UIFont.systemFont(ofSize: 22, weight: .bold) { didSet { setNeedsLayout() }}
    var text: String = "Icon" { didSet { refreshLayout() }}
    var icon: UIImage? { didSet { refreshLayout() }}
    
    private func refreshLayout() {
        _contentLayer = nil
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    private var textAttrString: NSAttributedString {
        let foregroundColor = isSelected ? selectedTextColor : textColor
        
        return NSAttributedString(string: text,
                                  attributes: [
                                    NSAttributedStringKey.font: font,
                                    NSAttributedStringKey.foregroundColor: foregroundColor
            ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentLayer.frame.align(to: CGPoint(x: bounds.midX, y: bounds.midY), using: .center)
    }
    
    override var intrinsicContentSize: CGSize {
        return contentLayer.frame.size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let minSize = contentLayer.frame.size
        
        return CGSize(width: size.width < minSize.width ? minSize.width : size.width,
                      height: size.height < minSize.height ? minSize.height : size.height)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            contentLayer.opacity = 0.5
        } else {
            print("impossible happened?")
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentLayer.opacity = 1.0

        guard let location = touches.first?.location(in: self) else { return }

        if point(inside: location, with: event) {
            sendActions(for: .touchUpInside)
        } else {
            sendActions(for: .touchUpOutside)
        }
    }
    
    // MARK: CALayers
    fileprivate var iconLayer: CALayer?
    fileprivate var textLayer: CATextLayer?
    
    override var isSelected: Bool {
        didSet {
            textLayer?.string = textAttrString
        }
    }
    
    private var _contentLayer: CALayer?
    fileprivate var contentLayer: CALayer {
        if _contentLayer == nil {
            _contentLayer = CALayer()
//            _contentLayer!.contentsGravity = kCAGravityCenter
//            _contentLayer!.backgroundColor = UIColor.cyan.cgColor
            
            let iconSize = icon?.size ?? .zero
            let textSize = textAttrString.size()
            let spacing = iconSize.width > 0 ? iconTextSpacing : 0
            
            let layerSize = CGSize(width: ceil(iconSize.width + spacing + textSize.width),
                                   height: ceil(max(iconSize.height, textSize.height)))
            _contentLayer!.frame = CGRect(origin: .zero, size: layerSize)
            
            var xOffset: CGFloat = 0
            
            if let icon = icon {
                let iconLayer = CALayer()
                iconLayer.contents = icon.cgImage
                iconLayer.contentsGravity = kCAGravityCenter
                iconLayer.isGeometryFlipped = true
                iconLayer.contentsScale = UIScreen.main.scale
                iconLayer.frame = CGRect(origin: CGPoint(x: 0,
                                                         y: round((layerSize.height - iconSize.height) / 2)),
                                         size: iconSize)
                
                _contentLayer!.addSublayer(iconLayer)
                xOffset += icon.size.width + iconTextSpacing
            }
            
            textLayer = CATextLayer()
            textLayer!.string = textAttrString
            textLayer!.contentsScale = UIScreen.main.scale
            textLayer!.frame = CGRect(x: xOffset,
                                      y: round((layerSize.height - textSize.height) / 2),
                                     width: textSize.width, height: textSize.height)
//            textLayer.backgroundColor = UIColor.magenta.cgColor
            
            _contentLayer!.addSublayer(textLayer!)
            layer.addSublayer(_contentLayer!)
        }

        return _contentLayer!
    }
}
