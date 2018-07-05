//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit
import Designables

class ResultsVC: UIViewController {
    @IBOutlet weak var viewControllersScrollView: UIScrollView!
    @IBOutlet weak var tabsHeadersView: TabHeadersView!
    
    private var currPage = 0 {
        didSet {
            guard isViewLoaded else { return }
        }
    }
    
    var viewModel: ResultsVCViewModel? {
        didSet {
            guard isViewLoaded else { return }
            
            setupView()
        }
    }
    
    struct PageManager<VC> {
        var index: Int = 0
        private let max = 3
        private var viewControllers: [VC] = []
        private var creationClosure: () -> VC
        
        init(creationClousure: @escaping () -> VC) {
            self.creationClosure = creationClousure
        }
    }
    
    private lazy var viewControllersPool: [ResultsContentVC] = {
        return (1...3).map({ (_) -> ResultsContentVC in
            let vc = ResultsContentVC(nibName: ResultsContentVC.className, bundle: nil)
            vc.view.tag = -1
            
            return vc
        })
    }()

    func updateViewControllersViews() {
        let width = viewControllersScrollView.bounds.width
        let height = viewControllersScrollView.bounds.height

        for vc in viewControllersPool {
            let page = vc.view.tag
            
            vc.view.isHidden = page < 0
            vc.view.frame = CGRect(x: CGFloat(page) * width, y: 0, width: width, height: height)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Your test results"
        viewControllersScrollView.delegate = self
        
        viewControllersPool.forEach { (vc) in
            self.viewControllersScrollView.addSubview(vc.view)
        }
        
        setupView()
        updateViewControllersViews()
    }
    
    private func setupView() {
        guard let vm = viewModel else { return }
        
        let specs = vm.map({ TabHeadersView.TabSpec(name: $0.testType.name, icon: $0.testType.smallIcon) })
        
        tabsHeadersView.tabSpecs = specs
        tabsHeadersView.delegate = self
        
        if vm.dataSourcesCount >= 1 {
            viewControllersPool[0].dataSource = vm.dataSource(at: 0)
            viewControllersPool[0].view.tag = 0
        }
        
        if vm.dataSourcesCount >= 2 {
            viewControllersPool[1].dataSource = vm.dataSource(at: 1)
            viewControllersPool[1].view.tag = 1
        }
        
        if vm.dataSourcesCount >= 3 {
            viewControllersPool[2].dataSource = vm.dataSource(at: 2)
            viewControllersPool[2].view.tag = 2
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let vm = viewModel else { return }
        
        viewControllersScrollView.contentSize = CGSize(
            width: viewControllersScrollView.bounds.width * CGFloat(vm.dataSourcesCount),
            height: viewControllersScrollView.bounds.height)
        
        updateViewControllersViews()
    }
}

extension ResultsVC: UIScrollViewDelegate {
    private func loadDataSource(page: Int) {
        guard let vm = viewModel, currPage != page else { return }
        
        var neededPages = [page-1, page, page+1].filter({ $0 >= 0 && $0 < vm.dataSourcesCount })
        var freeVCs: [ResultsContentVC] = []
        
        for vc in viewControllersPool {
            if let index = neededPages.index(of: vc.view.tag) {
                neededPages.remove(at: index)
            } else {
                freeVCs.append(vc)
            }
        }
        
        for p in neededPages {
            if freeVCs.count > 0 {
                let vc = freeVCs.removeFirst()
                
                DispatchQueue.main.async {
                    vc.view.tag = p
                    vc.dataSource = vm.dataSource(at: p)
                    vc.view.frame = CGRect(x: CGFloat(p) * self.viewControllersScrollView.bounds.width,
                                           y: 0,
                                           width: self.viewControllersScrollView.bounds.width,
                                           height: self.viewControllersScrollView.bounds.height)
                }
            }
        }
        
        currPage = page
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let vm = viewModel else { return }
        
        let normalizedOffset = scrollView.contentOffset.x / scrollView.contentSize.width
        let page = Int((normalizedOffset * CGFloat(vm.dataSourcesCount)).rounded())
        
        loadDataSource(page: page)
        
        DispatchQueue.main.async { [weak self] in
            self?.tabsHeadersView.tabIndicatorNormalizedOffsetX = normalizedOffset
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let vm = viewModel else { return }

        let normalizedOffset = scrollView.contentOffset.x / scrollView.contentSize.width
        let page = Int((normalizedOffset * CGFloat(vm.dataSourcesCount)).rounded())
        
        tabsHeadersView.tabIndicatorNormalizedOffsetX = nil
        tabsHeadersView.selectedTab = page

        currPage = page
    }
}

extension ResultsVC: TabHeadersViewDelegate {
    func tabSelected(_ view: TabHeadersView, previousIndex: Int, currentIndex: Int) {
        loadDataSource(page: currentIndex)
        
        let pageFrame = CGRect(x: CGFloat(currentIndex) * viewControllersScrollView.bounds.width,
                               y: 0,
                               width: viewControllersScrollView.bounds.width,
                               height: viewControllersScrollView.bounds.height)
        
        viewControllersScrollView.scrollRectToVisible(pageFrame, animated: true)
    }
}

struct ResultsVCViewModel: Sequence {
    private var dataSources: [ResultsDataSource]
    
    init(dataSources: [ResultsDataSource]) {
        self.dataSources = dataSources
    }
    
    var dataSourcesCount: Int {
        return dataSources.count
    }
    
    func dataSource(at index: Int) -> ResultsDataSource {
        return dataSources[index]
    }
    
    func makeIterator() -> IndexingIterator<[ResultsDataSource]> {
        return dataSources.makeIterator()
    }
}
