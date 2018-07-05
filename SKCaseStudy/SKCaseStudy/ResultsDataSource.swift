//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit
import Designables
import SharedLibrary

struct TestsFilter {
    var fromDate: Date
    var toDate: Date
    
    init(from: Date, to: Date) {
        self.fromDate = from
        self.toDate = to
    }
    
    static func lastWeekFromToday() -> TestsFilter {
        let now = Date()
        
        guard let fromDate = Calendar.current.date(byAdding: .day, value: -7, to: now) else {
            log.warning("The impossible happened! Check if you're dreaming.")
            
            return TestsFilter(from: Date(timeIntervalSinceNow: -3600 * 24 * 7), to: now)
        }
        
        return TestsFilter(from: fromDate, to: now)
    }
    
    static func lastMonthFromToday() -> TestsFilter {
        let now = Date()
        
        guard let fromDate = Calendar.current.date(byAdding: .day, value: -31, to: now) else {
            log.warning("The impossible happened! Check if you're dreaming.")
            
            return TestsFilter(from: Date(timeIntervalSinceNow: -3600 * 24 * 31), to: now)
        }
        
        return TestsFilter(from: fromDate, to: now)
    }
    
    static func lastYearFromToday() -> TestsFilter {
        let now = Date()
        
        guard let fromDate = Calendar.current.date(byAdding: .month, value: -12, to: now) else {
            log.warning("The impossible happened! Check if you're dreaming.")
            
            return TestsFilter(from: Date(timeIntervalSinceNow: -3600 * 24 * 365), to: now)
        }
        
         return TestsFilter(from: fromDate, to: now)
    }
}

protocol ResultsDataSource {
    var upToDate: Date { get }
    var testType: TestType { get }
    
    func values(for period: TimePeriod) -> [TestResult]
    func average(for period: TimePeriod) -> AverageResult
}

class BaseResultsDataSource: ResultsDataSource {
    let values: [TestResult]
    var upToDate: Date
    var testType: TestType {
        fatalError("this property must be overriden")
    }
    
    fileprivate init(values: [TestResult], upTo date: Date) {
        self.values = values
        self.upToDate = date
    }
    
    fileprivate func filter(period: TimePeriod) -> [TestResult] {
        guard let fromDate = Calendar.current.date(byAdding: period.component,
                                                   value: -period.amount,
                                                   to: upToDate) else {
            log.warning("The impossible happened! Check if you're dreaming.")
            
            return values
        }
        
        return values.filter({ $0.date >= fromDate && $0.date <= upToDate })
    }
    
    func values(for period: TimePeriod) -> [TestResult] {
        return filter(period: period)
    }
    
    func average(for period: TimePeriod) -> AverageResult {
        return average(values: filter(period: period))
    }
    
    fileprivate func average(values: [TestResult]) -> AverageResult {
        fatalError("this method must be overriden")
    }
}

class DownloadResultsDataSource: BaseResultsDataSource {
    override var testType: TestType {
        return .download
    }
    
    init(values: [DownloadTestResult], upTo date: Date) {
        super.init(values: values, upTo: date)
    }
    
    override func average(values: [TestResult]) -> AverageResult {
        guard values.count > 0 else { return AverageResult(value: nil, units: nil) }
        
        func pickBestUnit(items: [DownloadTestResult]) -> BitRateValue.BitRateUnit {
            return .mbps
        }
        
        let downloadItems = values as! [DownloadTestResult]
        
        // Choose best unit
        let rateUnit = pickBestUnit(items: downloadItems)
        var total: Double = 0
        
        for item in downloadItems {
            total += item.value.converted(to: rateUnit).double
        }
        
        return AverageResult(value: total / Double(values.count), units: rateUnit.description)
    }
}

class UploadResultsDataSource: BaseResultsDataSource {
    override var testType: TestType {
        return .upload
    }
    
    init(values: [UploadTestResult], upTo date: Date) {
        super.init(values: values, upTo: date)
    }
    
    override func average(values: [TestResult]) -> AverageResult {
        guard values.count > 0 else { return AverageResult(value: nil, units: nil) }
        
        func pickBestUnit(items: [UploadTestResult]) -> BitRateValue.BitRateUnit {
            return .mbps
        }
        
        let uploadItems = values as! [UploadTestResult]
        
        // Choose best unit
        let rateUnit = pickBestUnit(items: uploadItems)
        var total: Double = 0
        
        for item in uploadItems {
            total += item.value.converted(to: rateUnit).double
        }
        
        return AverageResult(value: total / Double(values.count), units: rateUnit.description)
    }
}

class JitterResultsDataSource: BaseResultsDataSource {
    override var testType: TestType {
        return .jitter
    }
    
    init(values: [JitterTestResult], upTo date: Date) {
        super.init(values: values, upTo: date)
    }
    
    override func average(values: [TestResult]) -> AverageResult {
        guard values.count > 0 else { return AverageResult(value: nil, units: nil) }
        
        func pickBestUnit(items: [JitterTestResult]) -> TimeValue.TimeUnit {
            return .milliseconds
        }
        
        let jitterItems = values as! [JitterTestResult]
        
        // Choose best unit
        let rateUnit = pickBestUnit(items: jitterItems)
        var total: Double = 0
        
        for item in jitterItems {
            total += item.value.converted(to: rateUnit).double
        }
        
        return AverageResult(value: total / Double(values.count), units: rateUnit.description)
    }
}

class LatencyResultsDataSource: BaseResultsDataSource {
    override var testType: TestType {
        return .latency
    }
    
    init(values: [LatencyTestResult], upTo date: Date) {
        super.init(values: values, upTo: date)
    }
    
    override func average(values: [TestResult]) -> AverageResult {
        guard values.count > 0 else { return AverageResult(value: nil, units: nil) }
        
        func pickBestUnit(items: [LatencyTestResult]) -> TimeValue.TimeUnit {
            return .milliseconds
        }
        
        let latencyItems = values as! [LatencyTestResult]
        
        // Choose best unit
        let rateUnit = pickBestUnit(items: latencyItems)
        var total: Double = 0
        
        for item in latencyItems {
            total += item.value.converted(to: rateUnit).double
        }
        
        return AverageResult(value: total / Double(values.count), units: rateUnit.description)
    }
}

class WebBrowsingResultsDataSource: BaseResultsDataSource {
    override var testType: TestType {
        return .webBrowsing
    }
    
    init(values: [WebBrowsingTestResult], upTo date: Date) {
        super.init(values: values, upTo: date)
    }
    
    override func average(values: [TestResult]) -> AverageResult {
        guard values.count > 0 else { return AverageResult(value: nil, units: nil) }
        
        func pickBestUnit(items: [WebBrowsingTestResult]) -> TimeValue.TimeUnit {
            return .seconds
        }
        
        let webBrowsingItems = values as! [WebBrowsingTestResult]
        
        // Choose best unit
        let rateUnit = pickBestUnit(items: webBrowsingItems)
        var total: Double = 0
        
        for item in webBrowsingItems {
            total += item.value.converted(to: rateUnit).double
        }
        
        return AverageResult(value: total / Double(values.count), units: rateUnit.description)
    }
}

class PacketLossResultsDataSource: BaseResultsDataSource {
    override var testType: TestType {
        return .packetLoss
    }
    
    init(values: [PacketLossTestResult], upTo date: Date) {
        super.init(values: values, upTo: date)
    }
    
    override func average(values: [TestResult]) -> AverageResult {
        guard values.count > 0 else { return AverageResult(value: nil, units: nil) }
        
        let packetLossItems = values as! [PacketLossTestResult]
        let average = packetLossItems.reduce(0, { $0 + $1.value }) / Double(packetLossItems.count)

        return AverageResult(value: average, units: "%")
    }
}

class YoutubeResultsDataSource: BaseResultsDataSource {
    override var testType: TestType {
        return .youtube
    }
    
    init(values: [YoutubeTestResult], upTo date: Date) {
        super.init(values: values, upTo: date)
    }
    
    override func average(values: [TestResult]) -> AverageResult {
        guard values.count > 0 else { return AverageResult(value: nil, units: nil) }
        
        let youtubeItems = values as! [YoutubeTestResult]
        var total: Double = 0
        
        for item in youtubeItems {
            total += item.value.doubleValue
        }
        
        let average = VideoQualityValue(doubleValue: total / Double(youtubeItems.count))
        
        return AverageResult(value: nil, units: average.description)
    }
}

struct AverageResult: CustomStringConvertible {
    var value: Double?
    var units: String?
    
    var description: String {
        var output = ""
        
        if let value = value {
            output += String(value)
        }
        
        if let units = units {
            output += units
        }
        
        return output
    }
}

protocol ResultsDataSources {
    var dataSources: [ResultsDataSource] { get }
    
    var downloadTestsDataSource: DownloadResultsDataSource { get }
    var uploadTestsDataSource: UploadResultsDataSource { get }
    var jitterTestsDataSource: JitterResultsDataSource { get }
    var latencyTestsDataSource: LatencyResultsDataSource { get }
    var webBrowsingTestsDataSource: WebBrowsingResultsDataSource { get }
    var packetLossTestsDataSource: PacketLossResultsDataSource { get }
    var youtubeTestsDataSource: YoutubeResultsDataSource { get }
}

enum TimePeriod {
    case week, month, year
    
    var component: Calendar.Component {
        switch self {
        case .week: fallthrough
        case .month: return .day
        case .year: return .month
        }
    }
    
    var amount: Int {
        switch self {
        case .week: return 7
        case .month: return 31
        case .year: return 12
        }
    }
}

enum TestType: String {
    case download, upload, latency, jitter
    case packetLoss, youtube, webBrowsing
    
    static let allCases: [TestType] = [download, upload, latency, jitter,
                                  packetLoss, youtube, webBrowsing]
    
    var cEnumValue: Int {
        switch self {
        case .download: return Int(CTT_Download.rawValue)
        case .upload: return Int(CTT_Upload.rawValue)
        case .latency: return Int(CTT_Latency.rawValue)
        case .jitter: return Int(CTT_Jitter.rawValue)
        case .packetLoss: return Int(CTT_PacketLoss.rawValue)
        case .youtube: return Int(CTT_Youtube.rawValue)
        case .webBrowsing: return Int(CTT_WebBrowsing.rawValue)
        }
    }
    
    var bigIcon: UIImage? {
        switch self {
        case .download: return UIImage(named: "icon_download")
        case .upload: return UIImage(named: "icon_upload")
        case .latency: return UIImage(named: "icon_latency")
        case .jitter: return UIImage(named: "icon_jitter")
        case .packetLoss: return UIImage(named: "icon_packetloss")
        case .youtube: return UIImage(named: "icon_youtube")
        case .webBrowsing: return UIImage(named: "icon_webbrowsing")
        }
    }
    
    var smallIcon: UIImage? {
        switch self {
        case .download: return UIImage(named: "s_icon_download")
        case .upload: return UIImage(named: "s_icon_upload")
        case .latency: return UIImage(named: "s_icon_latency")
        case .jitter: return UIImage(named: "s_icon_jitter")
        case .packetLoss: return UIImage(named: "s_icon_packetloss")
        case .youtube: return UIImage(named: "s_icon_youtube")
        case .webBrowsing: return UIImage(named: "s_icon_webbrowsing")
        }
    }
    
    var color: UIColor {
        switch self {
        case .download: return Color.testDownloadColor
        case .upload: return Color.testUploadColor
        case .latency: return Color.testLatencyColor
        case .jitter: return Color.testJitterColor
        case .packetLoss: return Color.testPacketLossColor
        case .youtube: return Color.testYoutubeColor
        case .webBrowsing: return Color.testWebBrowsingColor
        }
    }
    
    var name: String {
        switch self {
        case .download: return "Download"
        case .upload: return "Upload"
        case .latency: return "Latency"
        case .jitter: return "Jitter"
        case .packetLoss: return "Packet loss"
        case .youtube: return "Youtube"
        case .webBrowsing: return "Web browsing"
        }
    }
}

//extension ResultsDataSource {
//
//    func lastWeekAverage(now: Date) -> [Double] {
//        let days = 7
//        guard let pastDate = Calendar.current.date(byAdding: .day, value: -days, to: now) else {
//            log.warning("The impossible happened! Check if you're dreaming.")
//            return []
//        }
//
//        return lastDaysAverage(days: days, from: now, values: resultsData(from: pastDate, to: now))
//    }
//
//    func lastMonthAverage(now: Date) -> [Double] {
//        let days = 31
//        guard let pastDate = Calendar.current.date(byAdding: .day, value: -days, to: now) else {
//            log.warning("The impossible happened! Check if you're dreaming.")
//            return []
//        }
//
//        return lastDaysAverage(days: days, from: now, values: resultsData(from: pastDate, to: now))
//    }
//
//    func lastYearAverage(now: Date) -> [Double] {
//        let months = 12
//        guard let pastDate = Calendar.current.date(byAdding: .month, value: -months, to: now) else {
//            log.warning("The impossible happened! Check if you're dreaming.")
//            return []
//        }
//
//        return lastDaysAverage(days: months, from: now, values: resultsData(from: pastDate, to: now))
//    }
//}
