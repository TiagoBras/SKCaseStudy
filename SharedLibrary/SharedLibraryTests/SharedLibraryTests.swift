//
//  SharedLibraryTests.swift
//  SharedLibraryTests
//
//  Created by Tiago Bras on 22/05/2018.
//  Copyright © 2018 Tiago Bras. All rights reserved.
//

import XCTest
@testable import SharedLibrary

class SharedLibraryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let expectation = XCTestExpectation(description: "Test 1")
        
        let completion: InternetTest.CompletionHandler = { (tester, result, error) in
            if (error == CTE_ThreadCancelled) {
                print("Thread was cancelled")
            } else {
                print("Result: \(result)")
                print("Error: \(error)")
            }
            
            expectation.fulfill()
        }
        
        let progress: InternetTest.PartialResultHandler = { (tester, result) in
            print("Partial: \(result)")
        }
        
        let tester = InternetTest(config: CTestConfiguration(testType: CTT_Download),
                                completion: completion,
                                partial: progress)
        tester.run()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
            print("let's try cancel")
            tester.cancel()
        }
        
        wait(for: [expectation], timeout: 50)
    }
    
    func testExample2() {
        let expectation = XCTestExpectation(description: "Test 1")
        let config = TestConfiguration(tests: [CTT_Download, CTT_Upload, CTT_Latency])
        
        let task = InternetTester.run(config: config, completion: { (results) in
            print(results)
            expectation.fulfill()
        }, resultsHandler: { (cType, result, error) in
            if let error = error {
                print("Error: \(error)")
            }
            
            print("Result \(cType.rawValue): \(result)")
        }) { (cType, result) in
            print("Partial \(cType.rawValue): \(result)")
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            task.cancel()
//        }
        
        wait(for: [expectation], timeout: 50)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
