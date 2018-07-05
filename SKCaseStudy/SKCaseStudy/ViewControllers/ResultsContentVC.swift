//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit
import Designables

class ResultsContentVC: UIViewController {
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var averageUnitsLabel: UILabel!
    
    @IBAction func timePeriodValuedChanged(_ sender: UISegmentedControl) {
        let all: [TimePeriod] = [.week, .month, .year]
        
        timePeriod = all[sender.selectedSegmentIndex]
    }
    
    @IBAction func connectionTypeValueChanged(_ sender: UISegmentedControl) {
    }
    
    var dataSource: ResultsDataSource? {
        didSet {
            guard isViewLoaded else { return }
            
            DispatchQueue.main.async { [weak self] in
                if let dataSource = self?.dataSource, let timePeriod = self?.timePeriod {
                    self?.titleLabel.text = dataSource.testType.name
                    self?.iconImageView.image = dataSource.testType.bigIcon
                    
                    let avg = dataSource.average(for: timePeriod)
                    
                    self?.averageLabel.textColor = dataSource.testType.color
                    self?.averageLabel.text = "\((avg.value ?? 0).string(desiredDigitsCount: 2))"
                    self?.averageUnitsLabel.textColor = dataSource.testType.color
                    self?.averageUnitsLabel.text = avg.units
                }
                
                self?.barChartView.viewModel = self?.currentViewModel
                self?.tableView.reloadData()
            }
        }
    }
    
    var timePeriod: TimePeriod = .week {
        didSet {
            guard isViewLoaded else { return }
            
            barChartView.viewModel = currentViewModel
            tableView.reloadData()
        }
    }
    
    private var nowDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ResultsTableViewCell.nib, forCellReuseIdentifier: ResultsTableViewCell.className)
        barChartView.viewModel = currentViewModel
    }
    
    // MARK:- Private methods
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        
        return df
    }()
    
    private func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    // MARK:- Private fields
    private var currentViewModel: BarChartViewModel? {
        guard let dataSource = dataSource else { return nil }
        
        return barChartViewModel(dataSource: dataSource, forTimePeriod: timePeriod)
    }
    
    // MARK:- BarChart Calculations
    fileprivate func barChartViewModel(dataSource: ResultsDataSource,
                                       forTimePeriod timePeriod: TimePeriod) -> BarChartViewModel {
        let untilDate = dataSource.upToDate

        let filteredResults = dataSource.values(for: timePeriod)
        var doubleValues: [(date: Date, value: Double)] = []
        
        if let values = filteredResults as? [TestResult & HasBitRateValue] {
            doubleValues = values.map({ ($0.date, $0.value.converted(to: .mbps).double) })
        } else if let values = filteredResults as? [TestResult & HasTimeValue] {
            // TODO: create a method that chooses the best time unit
            //        let unit: TimeValue.TimeUnit = dataSource.testType == .webBrowsing ? .seconds : .milliseconds
            
            let unit: TimeValue.TimeUnit = .milliseconds
            
            doubleValues = values.map({ ($0.date, $0.value.converted(to: unit).double) })
        } else if let values = filteredResults as? [TestResult & HasDoubleValue] {
            doubleValues = values.map({ ($0.date, $0.value) })
        } else if let _ = filteredResults as? [TestResult & HasVideoQualityValue] {
            log.warning("mot implemented")
        } else if let _ = filteredResults as? [TestResult & HasTimeValue] {
            log.warning("mot implemented")
        } else {
            fatalError("\(type(of: filteredResults)) is an invalid ResultsDataSource type")
        }
        
        //    let doubleValues = values.map({ ($0.date, $0.value.converted(to: .mbps).value) })
        
        var viewModel = BarChartViewModel(values: [], labels: [])
        viewModel.boxColor = UIColor(red: 0.443, green: 0.506, blue: 0.557, alpha: 1.00)
        viewModel.barColor = dataSource.testType.color
        
        viewModel.xAxisLabelsPadding.left = viewModel.padding.left
        viewModel.xAxisLabelsPadding.right = viewModel.padding.right
        viewModel.barSpacing = 4.0
        
        switch timePeriod {
        case .week:
            let weekdayLabels = Calendar.current.shortWeekdaySymbols
            let currWeekday = Calendar.current.component(.weekday, from: Date())
            
            viewModel.values = lastDaysAverage(days: 7, from: untilDate, values: doubleValues).map({ CGFloat($0) })
            viewModel.labels = weekdayLabels.rotateLeft(times: currWeekday)
        case .month: break
        case .year: break
        }
        
        return viewModel
    }
    
    fileprivate func lastAverageOf(component: Calendar.Component,
                                   amount: Int,
                                   from: Date,
                                   values: [(date: Date, value: Double)]) -> [Double] {
        guard let startDate = Calendar.current.date(byAdding: component, value: -amount, to: from) else {
            log.warning("The impossible happened! Check if you're dreaming.")
            return []
        }
        let filteredValues = values.filter({ $0.date >= startDate })
        
        // bins[Sunday], bins[Monday], ...
        var counter: [(count: Int, total: Double)] = Array(repeating: (0, 0), count: amount)
        
        for data in filteredValues {
            guard let delta = Calendar.current.dateComponents(
                [component], from: startDate, to: data.date).value(for: component), delta < amount else {
                    log.warning("The impossible happened! Check if you're dreaming.")
                    continue
            }
            
            counter[delta].count += 1
            counter[delta].total += data.value
        }
        
        return counter.map({ (count: Int, total: Double) -> Double in
            guard total > 0 else { return 0 }
            
            return total / Double(count)
        })
    }
    
    fileprivate func lastDaysAverage(days: Int, from: Date, values: [(date: Date, value: Double)]) -> [Double] {
        return lastAverageOf(component: .day, amount: days, from: from, values: values)
    }
    
    fileprivate func lastMonthsAverage(months: Int, from: Date, values: [(date: Date, value: Double)]) -> [Double] {
        return lastAverageOf(component: .month, amount: months, from: from, values: values)
    }
}

extension ResultsContentVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.values(for: timePeriod).count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: ResultsTableViewCell.className,
                                             for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ResultsTableViewCell else { return }
        guard let result = dataSource?.values(for: timePeriod)[indexPath.row] else { return }
        
        if let data = result as? ResultsTableViewCellRepresentable {
            cell.setupView(data)
        }
    }
}

extension ResultsContentVC: UITableViewDelegate {
    
}
