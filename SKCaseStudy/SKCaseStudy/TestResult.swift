//  Copyright © 2018 Tiago Bras. All rights reserved.
import Foundation

protocol UsesDoubleForAverage {
    var doubleValue: Double { get }
}

protocol TestResult {
    var id: String { get set }
    var date: Date { get set }
}

// MARK:- Implementation (same file since they're small data structures)
struct DownloadTestResult: TestResult, HasBitRateValue {
    var id: String
    var date: Date
    var value: BitRateValue
}

struct UploadTestResult: TestResult, HasBitRateValue {
    var id: String
    var date: Date
    var value: BitRateValue
}

struct JitterTestResult: TestResult, HasTimeValue {
    var id: String
    var date: Date
    var value: TimeValue
}

struct LatencyTestResult: TestResult, HasTimeValue {
    var id: String
    var date: Date
    var value: TimeValue
}

struct WebBrowsingTestResult: TestResult, HasTimeValue {
    var id: String
    var date: Date
    var value: TimeValue
}

struct PacketLossTestResult: TestResult, HasDoubleValue {
    var id: String
    var date: Date
    var value: Double
}

struct YoutubeTestResult: TestResult, HasVideoQualityValue {
    var id: String
    var date: Date
    var value: VideoQualityValue
}

protocol HasDoubleValue {
    var value: Double { get }
}

// MARK:- BitRateValue
struct BitRateValue: CustomStringConvertible {
    var double: Double
    var unit: BitRateUnit {
        didSet {
            guard unit != oldValue else { return }
            
            double = double * (oldValue.rawValue / unit.rawValue)
        }
    }
    
    func converted(to newUnit: BitRateUnit) -> BitRateValue {
        var selfCopy = self
        selfCopy.unit = newUnit
        
        return selfCopy
    }
    
    enum BitRateUnit: Double, CustomStringConvertible {
        case bps = 1, kbps = 1_000, mbps = 1_000_000, gbps = 1_000_000_000
        
        var description: String {
            switch self {
            case .bps: return "bps"
            case .kbps: return "Kbps"
            case .mbps: return "Mbps"
            case .gbps: return "Gbps"
            }
        }
    }
    
    var description: String {
        let desiredDigitsCount = double < 0 ? 4 : 3
        let valueString = double.string(desiredDigitsCount: desiredDigitsCount)
        
        return "\(valueString)\(unit)"
    }
}

protocol HasBitRateValue {
    var value: BitRateValue { get set }
}

// MARK:- TimeValue
struct TimeValue: CustomStringConvertible {
    var double: Double
    var unit: TimeUnit {
        didSet {
            guard unit != oldValue else { return }
            
            double = double * (oldValue.rawValue / unit.rawValue)
        }
    }
    
    func converted(to newUnit: TimeUnit) -> TimeValue {
        var selfCopy = self
        selfCopy.unit = newUnit
        
        return selfCopy
    }
    
    enum TimeUnit: Double, CustomStringConvertible {
        case milliseconds = 1, seconds = 1_000, minutes = 60_000, hours = 3_600_000
        
        var description: String {
            switch self {
            case .milliseconds: return "ms"
            case .seconds: return "sec"
            case .minutes: return "min"
            case .hours: return "hour"
            }
        }
    }
    
    var description: String {
        let desiredDigitsCount = double < 0 ? 4 : 3
        let valueString = double.string(desiredDigitsCount: desiredDigitsCount)
        
        return "\(valueString)\(unit)"
    }
}

protocol HasTimeValue {
    var value: TimeValue { get set }
}

// MARK:- VideoQualityValue
enum VideoQualityValue: Int, CustomStringConvertible, Decodable {
    case sd = 1, hd = 2, uhd = 3
    
    static let allCases: [VideoQualityValue] = [.sd, .hd, .uhd]
    
    var doubleValue: Double {
        return Double(rawValue)
    }
    
    var description: String {
        switch self {
        case .sd: return "SD"
        case .hd: return "HD"
        case .uhd: return "UHD"
        }
    }
    
    init(doubleValue: Double) {
        let pairs = VideoQualityValue.allCases.map { (v) -> (quality: VideoQualityValue, diff: Double) in
            return (v, fabs(doubleValue - v.doubleValue))
        }
        
        guard let min = pairs.min(by: { $0.diff < $1.diff }) else {
            self.init(rawValue: VideoQualityValue.sd.rawValue)!
            return
        }
        
        self.init(rawValue: min.quality.rawValue)!
    }
}

protocol HasVideoQualityValue {
    var value: VideoQualityValue { get set }
}
