//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit
import Designables

// Simulate database
class RandomResultsDataSources: ResultsDataSources {
    let now = Date()
    
    var dataSources: [ResultsDataSource] {
        return [
            downloadTestsDataSource,
            uploadTestsDataSource,
            jitterTestsDataSource,
            latencyTestsDataSource,
            webBrowsingTestsDataSource,
            packetLossTestsDataSource,
            youtubeTestsDataSource
        ]
    }
    
    var downloadTestsDataSource: DownloadResultsDataSource {
        return DownloadResultsDataSource(values: downloadTests, upTo: now)
    }
    
    var uploadTestsDataSource: UploadResultsDataSource {
        return UploadResultsDataSource(values: uploadTests, upTo: now)
    }
    
    var jitterTestsDataSource: JitterResultsDataSource {
        return JitterResultsDataSource(values: jitterTests, upTo: now)
    }
    
    var latencyTestsDataSource: LatencyResultsDataSource {
        return LatencyResultsDataSource(values: latencyTests, upTo: now)
    }
    
    var webBrowsingTestsDataSource: WebBrowsingResultsDataSource {
        return WebBrowsingResultsDataSource(values: webBrowsingTests, upTo: now)
    }
    
    var packetLossTestsDataSource: PacketLossResultsDataSource {
        return PacketLossResultsDataSource(values: packetLossTests, upTo: now)
    }
    
    var youtubeTestsDataSource: YoutubeResultsDataSource {
        return YoutubeResultsDataSource(values: youtubeTests, upTo: now)
    }
    
    private var spec: TestsCountSpecification
    
    init(spec: TestsCountSpecification) {
        self.spec = spec
    }
    
    // MARK:- Private Methods
    private func filtered<T: TestResult>(results: [T], with filter: TestsFilter) -> [T] {
        return results.filter({ $0.date >= filter.fromDate && $0.date <= filter.toDate })
    }
    
    private lazy var downloadTests: [DownloadTestResult] = {
        return randomBitRateValue(minMbps: spec.download.minMbps, maxMbps: spec.download.maxMbps) {
            (id, date, value) -> DownloadTestResult in
            
            return DownloadTestResult(id: id, date: date, value: value)
        }
    }()
    
    private lazy var uploadTests: [UploadTestResult] = {
        return randomBitRateValue(minMbps: spec.upload.minMbps, maxMbps: spec.upload.maxMbps) {
            (id, date, value) -> UploadTestResult in
            
            return UploadTestResult(id: id, date: date, value: value)
        }
    }()
    
    private lazy var jitterTests: [JitterTestResult] = {
        return randomTimeValue(minSecs: spec.jitter.minSecs, maxSecs: spec.jitter.maxSecs) {
            (id, date, value) -> JitterTestResult in
            
            return JitterTestResult(id: id, date: date, value: value)
        }
    }()
    
    private lazy var latencyTests: [LatencyTestResult] = {
        return randomTimeValue(minSecs: spec.jitter.minSecs, maxSecs: spec.jitter.maxSecs) {
            (id, date, value) -> LatencyTestResult in
            
            return LatencyTestResult(id: id, date: date, value: value)
        }
    }()
    
    private lazy var webBrowsingTests: [WebBrowsingTestResult] = {
        return randomTimeValue(minSecs: spec.webBrowsing.minSecs, maxSecs: spec.webBrowsing.maxSecs) {
            (id, date, value) -> WebBrowsingTestResult in
            
            return WebBrowsingTestResult(id: id, date: date, value: value)
        }
    }()
    
    private lazy var packetLossTests: [PacketLossTestResult] = {
        return randomDoubleValue(min: spec.packetLoss.min, max: spec.packetLoss.max) {
            (id, date, value) -> PacketLossTestResult in
            
            return PacketLossTestResult(id: id, date: date, value: value)
        }
    }()
    
    private lazy var youtubeTests: [YoutubeTestResult] = {
        return randomIntValue(values: VideoQualityValue.allCases.map({ $0.rawValue })) {
            (id, date, value) -> YoutubeTestResult? in
            guard let quality = VideoQualityValue(rawValue: value) else { return nil }
            
            return YoutubeTestResult(id: id, date: date, value: quality)
        }
    }()
    
    // MARK:- Random Methods
    private func randomBitRateValue<T>(minMbps: Double,
                                       maxMbps: Double,
                                       map: (String, Date, BitRateValue) -> T) -> [T] {
        let datesIds = spec.genDatesAndIds()
        
        return datesIds.sorted(by: { $0.key < $1.key }).map({ (r) -> T in
            let randomValue = BitRateValue(double: Double.random(min: minMbps, max: maxMbps), unit: .mbps)
            
            return map(r.value, r.key, randomValue)
        })
    }
    
    private func randomTimeValue<T>(minSecs: Double,
                                    maxSecs: Double,
                                    map: (String, Date, TimeValue) -> T) -> [T] {
        return spec.genDatesAndIds().sorted(by: { $0.key < $1.key }).map({ (r) -> T in
            let randomValue = TimeValue(double: Double.random(min: minSecs, max: maxSecs), unit: .seconds)
            
            return map(r.value, r.key, randomValue)
        })
    }
    
    private func randomDoubleValue<T>(min: Double,
                                      max: Double,
                                      map: (String, Date, Double) -> T) -> [T] {
        return spec.genDatesAndIds().sorted(by: { $0.key < $1.key }).map({ (r) -> T in
            let randomValue = Double.random(min: min, max: max)
            
            return map(r.value, r.key, randomValue)
        })
    }
    
    private func randomIntValue<T>(values: [Int],
                                   map: (String, Date, Int) -> T?) -> [T] {
        return spec.genDatesAndIds().sorted(by: { $0.key < $1.key }).compactMap({ (r) -> T? in
            let index = Int(arc4random_uniform(UInt32(values.count)))

            return map(r.value, r.key, values[index])
        })
    }
}

//fileprivate class BitRateTestDataSource: ResultsDataSource {
//    var testType: TestType
//    fileprivate var values: [BitRateValueTestResult] = []
//
//    init(testType: TestType, spec: TestsCountSpecification, minMbps: Double, maxMbps: Double) {
//        self.testType = testType
//
//        values = spec.genDatesAndIds().sorted(by: { $0.key < $1.key }).map {
//            (date: Date, id: String) -> BitRateValueTestResult in
//            // Download & Upload share the same structure
//            return DownloadTestResult(id: id,
//                                      date: date,
//                                      value: BitRateValue(value: randomDouble(min: minMbps, max: maxMbps),
//                                                          unit: .mbps))
//        }
//    }
//
//    func averageText(forTimePeriod timePeriod: TimePeriod, untilDate: Date) -> String {
//
//    }
//}
//
//fileprivate class TimeValueTestDataSource: ResultsDataSource {
//    var testType: TestType
//    fileprivate var values: [TimeValueTestResult] = []
//
//    init(testType: TestType, spec: TestsCountSpecification, minSecs: Double, maxSecs: Double) {
//        self.testType = testType
//
//        values = spec.genDatesAndIds().sorted(by: { $0.key < $1.key }).map {
//            (date: Date, id: String) -> TimeValueTestResult in
//            // Latency, Jitter & WebBrowsing share the same structure
//            return LatencyTestResult(id: id,
//                                     date: date,
//                                     value: TimeValue(value: randomDouble(min: minSecs, max: maxSecs),
//                                                      unit: .seconds))
//        }
//    }
//
//    //    func resultsData(from: Date, to: Date) -> [ResultsData] {
//    //        return values.filter({ $0.date >= from && $0.date <= to }).map({
//    //            (date: $0.date, $0.value.converted(to: .seconds).value)
//    //        })
//    //    }
//
//    func results(forTimePeriod timePeriod: TimePeriod, untilDate: Date) -> [TestResult] {
//        guard let fromDate = Calendar.current.date(byAdding: timePeriod.component,
//                                                   value: -timePeriod.amount,
//                                                   to: untilDate) else {
//                                                    log.warning("This should not happen! Noooooo!")
//                                                    return []
//        }
//
//        return values.filter({ $0.date >= fromDate && $0.date <= untilDate })
//    }
//
//    func barChartViewModel(forTimePeriod timePeriod: TimePeriod, untilDate: Date) -> BarChartViewModel {
//        return BarChartViewModel(values: [], labels: [])
//    }
//}
//
//fileprivate class PercentageValueTestDataSource: ResultsDataSource {
//    var testType: TestType
//    fileprivate var values: [PercentageValueTestResult] = []
//
//    init(testType: TestType, spec: TestsCountSpecification, minPercentage: Double, maxPercentage: Double) {
//        self.testType = testType
//
//        values = spec.genDatesAndIds().sorted(by: { $0.key < $1.key }).map {
//            (date: Date, id: String) -> PercentageValueTestResult in
//            // Latency, Jitter & WebBrowsing share the same structure
//            return PacketLossTestResult(id: id,
//                                        date: date,
//                                        value: randomDouble(min: minPercentage, max: maxPercentage))
//        }
//    }
//
//    //    func resultsData(from: Date, to: Date) -> [ResultsData] {
//    //        return values.filter({ $0.date >= from && $0.date <= to }).map({
//    //            (date: $0.date, $0.value)
//    //        })
//    //    }
//
//    func results(forTimePeriod timePeriod: TimePeriod, untilDate: Date) -> [TestResult] {
//        guard let fromDate = Calendar.current.date(byAdding: timePeriod.component,
//                                                   value: -timePeriod.amount,
//                                                   to: untilDate) else {
//                                                    log.warning("This should not happen! Noooooo!")
//                                                    return []
//        }
//
//        return values.filter({ $0.date >= fromDate && $0.date <= untilDate })
//    }
//
//    func barChartViewModel(forTimePeriod timePeriod: TimePeriod, untilDate: Date) -> BarChartViewModel {
//        return BarChartViewModel(values: [], labels: [])
//    }
//}
//
//fileprivate class VideoQualityValueTestDataSource: ResultsDataSource {
//    var testType: TestType
//    fileprivate var values: [VideoQualityValueTestResult] = []
//
//    init(testType: TestType, spec: TestsCountSpecification, possibleValues: [VideoQualityValue]) {
//        self.testType = testType
//
//        values = spec.genDatesAndIds().sorted(by: { $0.key < $1.key }).map {
//            (date: Date, id: String) -> VideoQualityValueTestResult in
//
//            let index = Int(arc4random_uniform(UInt32(possibleValues.count)))
//
//            return YoutubeTestResult(id: id,
//                                     date: date,
//                                     value: possibleValues[index])
//        }
//    }
//
//    //    func resultsData(from: Date, to: Date) -> [ResultsData] {
//    //        return values.filter({ $0.date >= from && $0.date <= to }).map({
//    //            (date: $0.date, $0.value.doubleValue)
//    //        })
//    //    }
//
//    func results(forTimePeriod timePeriod: TimePeriod, untilDate: Date) -> [TestResult] {
//        guard let fromDate = Calendar.current.date(byAdding: timePeriod.component,
//                                                   value: -timePeriod.amount,
//                                                   to: untilDate) else {
//                                                    log.warning("This should not happen! Noooooo!")
//                                                    return []
//        }
//
//        return values.filter({ $0.date >= fromDate && $0.date <= untilDate })
//    }
//
//    func barChartViewModel(forTimePeriod timePeriod: TimePeriod, untilDate: Date) -> BarChartViewModel {
//        return BarChartViewModel(values: [], labels: [])
//    }
//}


struct TestsCountSpecification: Decodable {
    var minTestsPerDay: UInt32
    var maxTestsPerDay: UInt32
    var startDate: Date
    
    var download: BitRateSpec = BitRateSpec(minMbps: 10, maxMbps: 90)
    var upload: BitRateSpec = BitRateSpec(minMbps: 10, maxMbps: 60)
    var jitter: TimeSpec = TimeSpec(minSecs: 0, maxSecs: 0.2)
    var webBrowsing: TimeSpec = TimeSpec(minSecs: 0, maxSecs: 3)
    var latency: TimeSpec = TimeSpec(minSecs: 0, maxSecs: 0.7)
    var packetLoss: DoubleSpec = DoubleSpec(min: 0, max: 2)
    var youtube: [VideoQualityValue] = VideoQualityValue.allCases
    
    init(minTestsPerDay: UInt32, maxTestsPerDay: UInt32, startDate: Date) {
        self.minTestsPerDay = minTestsPerDay
        self.maxTestsPerDay = maxTestsPerDay < minTestsPerDay ? minTestsPerDay : maxTestsPerDay
        self.startDate = startDate
    }

    /// Initialize Spec with contents of spec plist
    ///
    /// - Parameter specURL: plist file URL
    static func fromPList(url: URL) throws -> TestsCountSpecification {
        let data = try Data(contentsOf: url)
        
        return try PropertyListDecoder().decode(TestsCountSpecification.self, from: data)
    }
    
    func genDatesAndIds() -> [Date: String] {
        let nowDate = Date()
        var daysOffset = 0
        var date: Date = startDate
        var output: [Date: String] = [:]
        
        while (true) {
            // Generate N random results for X day
            for _ in 0..<UInt32.random(min: minTestsPerDay, max: maxTestsPerDay) {
                var dt = DateComponents()
                dt.day = daysOffset
                dt.hour = Int(UInt32.random(min: 8, max: 23))
                dt.minute = Int(UInt32.random(min: 0, max: 59))
                dt.second = Int(UInt32.random(min: 0, max: 59))
                
                guard let currDate = Calendar.current.date(byAdding: dt, to: startDate) else {
                    log.error("should not happen")
                    return output
                }
                
                date = currDate
                
                // Generate random ID
                let p1 = UInt32.random(min: 10_000, max: 99_999)
                let p2 = UInt32.random(min: 10_000, max: 99_999)

                output[date] = "\(p1)\(p2)"
            }
            
            if date > nowDate {
                break
            }
            
            daysOffset += 1
        }

        return output
    }
    
    struct BitRateSpec: Decodable {
        var minMbps: Double
        var maxMbps: Double
    }
    
    struct TimeSpec: Decodable {
        var minSecs: Double
        var maxSecs: Double
    }
    
    struct DoubleSpec: Decodable {
        var min: Double
        var max: Double
    }
}
