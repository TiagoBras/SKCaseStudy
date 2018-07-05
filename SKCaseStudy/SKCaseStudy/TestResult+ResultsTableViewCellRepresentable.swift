//  Copyright © 2018 Tiago Bras. All rights reserved.
import UIKit

fileprivate let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .long
    df.timeStyle = .short
    
    return df
}()

fileprivate func format(date: Date) -> String {
    return dateFormatter.string(from: date)
}

extension DownloadTestResult: ResultsTableViewCellRepresentable {
    var valueText: String {
        return String(describing: value)
    }
    var valueColor: UIColor {
        return TestType.download.color
    }
    var icon: UIImage? {
        return TestType.download.bigIcon
    }
    var idText: String {
        return id
    }
    var dateText: String {
        return format(date: date)
    }
}

extension UploadTestResult: ResultsTableViewCellRepresentable {
    var valueText: String {
        return String(describing: value)
    }
    var valueColor: UIColor {
        return TestType.upload.color
    }
    var icon: UIImage? {
        return TestType.upload.bigIcon
    }
    var idText: String {
        return id
    }
    var dateText: String {
        return format(date: date)
    }
}

extension JitterTestResult: ResultsTableViewCellRepresentable {
    var valueText: String {
        return String(describing: value)
    }
    var valueColor: UIColor {
        return TestType.jitter.color
    }
    var icon: UIImage? {
        return TestType.jitter.bigIcon
    }
    var idText: String {
        return id
    }
    var dateText: String {
        return format(date: date)
    }
}

extension LatencyTestResult: ResultsTableViewCellRepresentable {
    var valueText: String {
        return String(describing: value)
    }
    var valueColor: UIColor {
        return TestType.latency.color
    }
    var icon: UIImage? {
        return TestType.latency.bigIcon
    }
    var idText: String {
        return id
    }
    var dateText: String {
        return format(date: date)
    }
}

extension WebBrowsingTestResult: ResultsTableViewCellRepresentable {
    var valueText: String {
        return String(describing: value)
    }
    var valueColor: UIColor {
        return TestType.webBrowsing.color
    }
    var icon: UIImage? {
        return TestType.webBrowsing.bigIcon
    }
    var idText: String {
        return id
    }
    var dateText: String {
        return format(date: date)
    }
}

extension PacketLossTestResult: ResultsTableViewCellRepresentable {
    var valueText: String {
        return "\(value)%"
    }
    var valueColor: UIColor {
        return TestType.packetLoss.color
    }
    var icon: UIImage? {
        return TestType.packetLoss.bigIcon
    }
    var idText: String {
        return id
    }
    var dateText: String {
        return format(date: date)
    }
}

extension YoutubeTestResult: ResultsTableViewCellRepresentable {
    var valueText: String {
        return String(describing: value)
    }
    var valueColor: UIColor {
        return TestType.youtube.color
    }
    var icon: UIImage? {
        return TestType.youtube.bigIcon
    }
    var idText: String {
        return id
    }
    var dateText: String {
        return format(date: date)
    }
}

