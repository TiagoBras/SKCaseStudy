//  Copyright © 2018 Tiago Bras. All rights reserved.
import Foundation

final class Logger {
    struct Configuration {
        var showTimestamp: Bool
        var showFileName: Bool
        var showFunctionName: Bool
        var showLineNumber: Bool
        
        init(showTimestamp: Bool = true,
             showFileName: Bool = true,
             showFunctionName: Bool = true,
             showLineNumber: Bool = true) {
            self.showTimestamp = showTimestamp
            self.showFileName = showFileName
            self.showFunctionName = showFunctionName
            self.showLineNumber = showLineNumber
        }
    }
    
    enum LogLevel: Int, Comparable {
        static func <(lhs: Logger.LogLevel, rhs: Logger.LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        case error = 4, warning = 3, debug = 2, info = 1
        
        var name: String {
            switch self {
            case .error: return "❤️ ERROR"
            case .warning: return "💛 WARNING"
            case .debug: return "💙 DEBUG"
            case .info: return "💚 INFO"
            }
        }
    }
    
    var level: LogLevel
    var configuration: Configuration
    
    init(level: LogLevel = .info, configuration: Configuration = Configuration()) {
        self.level = level
        self.configuration = configuration
    }
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private class func now() -> String {
        return dateFormatter.string(from: Date())
    }
    
    private func log(_ items: [Any], level: LogLevel, separator: String, terminator: String,
             fileName: String, functionName: String, lineNumber: Int) {
        var output = ""
        
        if configuration.showTimestamp {
            output += "\(Logger.now()) "
        }
        
        output += "\(level.name)"
        
        if configuration.showFileName {
            if let lastComponent = fileName.split(separator: "/").last {
                output += " \(lastComponent)"
            }
        }
        
        if configuration.showFunctionName {
            output += " \(functionName)"
        }
        
        if configuration.showLineNumber {
            output += " [\(lineNumber)]"
        }
        
        output += ": "
        output += items.map({ String(reflecting: $0) }).joined(separator: separator)

        print(output, separator: separator, terminator: terminator)
    }
    
    func info(_ items: Any..., separator: String = " ", terminator: String = "\n",
              fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        #if DEBUG
            if level <= .info {
                log(items, level: .info, separator: separator, terminator: terminator,
                    fileName: fileName, functionName: functionName, lineNumber: lineNumber)
            }
        #endif
    }
    
    func debug(_ items: Any..., separator: String = " ", terminator: String = "\n",
               fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        #if DEBUG
            if level <= .debug {
                log(items, level: .debug, separator: separator, terminator: terminator,
                    fileName: fileName, functionName: functionName, lineNumber: lineNumber)
            }
        #endif
    }
    
    func warning(_ items: Any..., separator: String = " ", terminator: String = "\n",
                 fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        #if DEBUG
            if level <= .warning {
                log(items, level: .warning, separator: separator, terminator: terminator,
                    fileName: fileName, functionName: functionName, lineNumber: lineNumber)
            }
        #endif
    }
    
    func error(_ items: Any..., separator: String = " ", terminator: String = "\n",
               fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        log(items, level: .error, separator: separator, terminator: terminator,
            fileName: fileName, functionName: functionName, lineNumber: lineNumber)
    }
    
    static let shared: Logger = {
        return Logger(level: .info)
    }()
}
