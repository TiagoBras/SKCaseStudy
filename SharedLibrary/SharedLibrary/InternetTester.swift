//  Copyright © 2018 Tiago Bras. All rights reserved.
import Foundation

public struct TestConfiguration {
    var tests: [CTestType]
}

public class InternetTester {
    public enum TestError: Error {
        case outOfMemory
        case couldNotCreateThread
        case cancelled
        case unknown
        
        public init(cError: CTestError) {
            switch cError {
            case CTE_OutOfMemory: self = .outOfMemory
            case CTE_ThreadCancelled: self = .cancelled
            case CTE_CouldNotCreateThread: self = .couldNotCreateThread
            default: self = .unknown
            }
        }
    }
    
    public struct Results: CustomStringConvertible {
        public var download: Double? = nil
        public var upload: Double? = nil
        public var latency: Double? = nil
        public var jitter: Double? = nil
        public var packetLoss: Double? = nil
        public var youtube: Double? = nil
        public var webBrowsing: Double? = nil
        init() {}
        
        mutating func set(value: Double, for testType: CTestType) {
            switch testType {
            case CTT_Download: download = value
            case CTT_Upload: upload = value
            case CTT_Latency: latency = value
            case CTT_Jitter: jitter = value
            case CTT_PacketLoss: packetLoss = value
            case CTT_Youtube: youtube = value
            case CTT_WebBrowsing: webBrowsing = value
            default: return
            }
        }
        
        public var description: String {
            var lines = Array<String>()
            
            if let download = download { lines.append("download: \(download)") }
            if let upload = upload { lines.append("upload: \(upload)") }
            if let latency = latency { lines.append("latency: \(latency)") }
            if let jitter = jitter { lines.append("jitter: \(jitter)") }
            if let packetLoss = packetLoss { lines.append("packetLoss: \(packetLoss)") }
            if let youtube = youtube { lines.append("youtube: \(youtube)") }
            if let webBrowsing = webBrowsing { lines.append("webBrowsing: \(webBrowsing)") }
            
            return lines.count > 0 ? lines.joined(separator: "\n") : "No Results"
        }
    }
    
    public typealias CompletionHandler = (Results) -> ()
    public typealias ResultsHandler = (CTestType, Double, TestError?) -> ()
    public typealias PartialResultHandler = (CTestType, Double) -> ()
    
    public struct TestManager {
        private var cancelHandler: () -> ()
        fileprivate init(cancelHandler: @escaping () -> ()) {
            self.cancelHandler = cancelHandler
        }
        
        public func cancel() {
            cancelHandler()
        }
    }
    
    @discardableResult
    public static func run(config: TestConfiguration,
                    completion: @escaping CompletionHandler,
                    resultsHandler: ResultsHandler?,
                    partialHandler: PartialResultHandler?) -> TestManager {
        var queue = DispatchQueue(label: "TestQueue")
        var mutableConfig = config
        var results = Results()
        var shouldCancel = false
    
        func testCompletion(test: InternetTest, result: Double, cError: CTestError) {
            guard cError.rawValue == 0 else {
                resultsHandler?(test.config.testType, result, TestError(cError: cError))

                return
            }
            
            results.set(value: result, for: test.config.testType)
            
            resultsHandler?(test.config.testType, result, nil)
        }
        
        var currentTest: InternetTest?
        
        func runNextTest() {
            guard mutableConfig.tests.count > 0 && !shouldCancel else {
                return completion(results)
            }
            
            let testConfig = CTestConfiguration(testType: mutableConfig.tests.removeFirst())
            
            let completion: InternetTest.CompletionHandler = { (test, result, error) in
                testCompletion(test: test, result: result, cError: error)
                runNextTest()
            }
            
            let partial: InternetTest.PartialResultHandler = { (test, result) in
                partialHandler?(test.config.testType, result)
            }
            
            queue.sync {
                currentTest = InternetTest(config: testConfig,
                                           completion: completion,
                                           partial: partial)
                currentTest?.run()
            }
        }
        
        runNextTest()
        
        return TestManager {
            queue.sync {
                shouldCancel = true
                
                currentTest?.cancel()
            }
        }
    }
}

class InternetTest {
    typealias CompletionHandler = (InternetTest, Double, CTestError) -> ()
    typealias PartialResultHandler = (InternetTest, Double) -> ()
    
    private(set) var config: CTestConfiguration
    private var completion: CompletionHandler
    private var partial: PartialResultHandler? = nil
    private var isRunning = false
    
    init(config: CTestConfiguration, completion: @escaping CompletionHandler) {
        self.config = config
        self.completion = completion
    }
    
    init(config: CTestConfiguration,
         completion: @escaping CompletionHandler,
         partial: @escaping PartialResultHandler) {
        self.config = config
        self.completion = completion
        self.partial = partial
    }
    
    func run() {
        guard !isRunning else { return }
        
        isRunning = true
        
        let mySelf = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        
        run_test(config, mySelf, { (observer, result, error) in
            guard let observer = observer else { return }
            
            let mySelf = Unmanaged<InternetTest>.fromOpaque(observer).takeRetainedValue()
            
            mySelf.isRunning = false
            mySelf.completion(mySelf, result, error)
        }) { (observer, partial) in
            guard let observer = observer else { return }
            
            let mySelf = Unmanaged<InternetTest>.fromOpaque(observer).takeUnretainedValue()
            
            mySelf.partial?(mySelf, partial)
        }
    }
    
    func cancel() {
        cancel_test(UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
}
