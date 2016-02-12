//
//  PxePlayerErrorTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 10/24/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

import UIKit
import XCTest
import Foundation

class PxePlayerErrorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testErrorForCode() {
        let errorCode: PxePlayerErrorCode = .InvalidURL
        let error: NSError = PxePlayerError.errorForCode( errorCode )
        
        XCTAssertEqual(error.domain, PxePlayerErrorDomain, "Not Generating Correct PxePlayerError")
        XCTAssertEqual(error.localizedDescription, PxePlayerError.getLocalizedStringForErrorCode(errorCode), "Not Generating Correct PxePlayerError")
        
        let codeCompare: Int = errorCode.rawValue as Int
        XCTAssertEqual(error.code, codeCompare, "Not Generating Correct PxePlayerError")
    }

    func testErrorForCodeLocalizedString() {
        let errorCode: PxePlayerErrorCode = .MalformedURL
        let errorString: String = "http://bad.URl.com"
        let error: NSError = PxePlayerError.errorForCode( errorCode, localizedString:errorString )
        
        XCTAssertEqual(error.domain, PxePlayerErrorDomain, "Not Generating Correct PxePlayerError")
        XCTAssertEqual(error.localizedDescription, errorString, "Not Generating Correct PxePlayerError")
        
        let codeCompare: Int = errorCode.rawValue as Int
        XCTAssertEqual(error.code, codeCompare, "Not Generating Correct PxePlayerError")
    }
    
    func testErrorForCodeErrorDetail() {
        let errorCode: Int = 404;
        let errorDict: Dictionary = [NSLocalizedDescriptionKey:NSLocalizedString("No Results found", comment: "No Results found")];
        let error: NSError = PxePlayerError.errorForCode(errorCode, errorDetail: errorDict)
        
        XCTAssertEqual(error.domain, PxePlayerErrorDomain, "Not Generating Correct PxePlayerError")
        
        let keyString: String = errorDict[NSLocalizedDescriptionKey]!
        XCTAssertEqual(error.localizedDescription, keyString, "Not Generating Correct PxePlayerError")
        
        XCTAssertEqual(error.code, errorCode, "Not Generating Correct PxePlayerError")
    }

    func testPerformanceGetLocalizedStings() {
        self.measureBlock() {
            _ = PxePlayerError.getLocalizedStrings()
        }
    }

}
