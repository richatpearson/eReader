//
//  PxePlayerPageViewOptionsTest.swift
//  PxeReader
//
//  Created by Tomack, Barry on 1/4/16.
//  Copyright © 2016 Pearson. All rights reserved.
//

import XCTest

class PxePlayerPageViewOptionsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        XCTAssertNotNil(pxePlayerPageViewOptions, "Expected a new instance of PxePlayerPageViewoptions")
        
        XCTAssertTrue(pxePlayerPageViewOptions.showAnnotate, "Expected default value of showAnnotate to be true for new instance of PxePlayerPageViewOptions")
        XCTAssertFalse(pxePlayerPageViewOptions.enableMathML, "Expected default value of enableMathML to be false for new instance of PxePlayerPageViewOptions")
        XCTAssertFalse(pxePlayerPageViewOptions.printPageSupport, "Expected default value of printPageSupport to be false for new instance of PxePlayerPageViewOptions")
        
        XCTAssertEqual(pxePlayerPageViewOptions.hostWhiteList().count, 1, "Expected the host whitelist to have 1 entry for new instance of PxePlayerPageViewOptions")
        
        XCTAssertTrue(pxePlayerPageViewOptions.useDefaultFontAndTheme, "Expected default value of useDefaultFontAndTheme to be true for new instance of PxePlayerPageViewOptions")
        
        XCTAssertEqual(pxePlayerPageViewOptions.transitionStyle, 0, "Expected the transitionStyle to be UIPageViewControllerTransitionStylePageCurl for new instance of PxePlayerPageViewOptions")
    }
    
    func testBookPageDefaultFontSize(){
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        let defaultFontSize: Int! = pxePlayerPageViewOptions.fontSize
        
        XCTAssertEqual(defaultFontSize, 14, "Expected the default font size to be equal to the constant PXEPLAYER_DEFAULT_FONTSIZE of 14")
    }
    
    func testBookPageCustomFontSize(){
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        pxePlayerPageViewOptions.fontSize = 18
        
        let customFontSize: Int! = pxePlayerPageViewOptions.fontSize
        
        XCTAssertEqual(customFontSize, 18, "Expected the custom font size to be equal to 18")
    }
    
    func testBookPageCustomFontSizeBelowWMinimum(){
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        pxePlayerPageViewOptions.fontSize = 8
        
        let customFontSize: Int! = pxePlayerPageViewOptions.fontSize
        
        XCTAssertEqual(customFontSize, 10, "Expected the custom font size to be equal to the minimum font size 10")
    }
    
    func testBookPageCustomFontSizeAboveMaximum(){
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        pxePlayerPageViewOptions.fontSize = 30
        
        let customFontSize: Int! = pxePlayerPageViewOptions.fontSize
        
        XCTAssertEqual(customFontSize, 28, "Expected the custom font size to be equal to the maximum font size 28")
    }
    
    func testBookPageDefaultTheme(){
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        let defaultTheme: String! = pxePlayerPageViewOptions.bookTheme
        
        XCTAssertEqual(defaultTheme, "day", "Expected the default theme to be equal to the constant PXEPLAYER_DEFAULT_THEME of \"day\"")
    }
    
    func testBookPageCustomTheme(){
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        pxePlayerPageViewOptions.bookTheme = "night"
        
        let customTheme: String! = pxePlayerPageViewOptions.bookTheme
        
        XCTAssertEqual(customTheme, "night", "Expected the custom theme to be equal to \"night\"")
    }
    
    func testBookPageCustomThemeAsNil(){
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        pxePlayerPageViewOptions.bookTheme = nil
        
        let customTheme: String! = pxePlayerPageViewOptions.bookTheme
        
        XCTAssertEqual(customTheme, "day", "Expected the custom theme to be equal to \"day\" by default")
    }
    
    func testAddHostToWhiteListWithHost() {
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        let newHost = "www.pearson.com"
        
        pxePlayerPageViewOptions.addHostToWhiteList(newHost)
        
        let hostWhiteList: [String] = pxePlayerPageViewOptions.hostWhiteList() as NSArray as! [String] //Double downcast
        
        let contained: Bool = hostWhiteList.contains(newHost)
        
        XCTAssertTrue(contained, "Expected the host whitelist to contain the new host we added")
        
        XCTAssertEqual(hostWhiteList.count, 2, "Expected the host whitelist to have a count of 2...the default entry plus the new entry")
    }
    
    func testAddHostToWhiteListWithURL() {
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        let newHost = "http://www.pearson.com/url"
        
        pxePlayerPageViewOptions.addHostToWhiteList(newHost)
        
        let hostWhiteList: [String] = pxePlayerPageViewOptions.hostWhiteList() as NSArray as! [String] //Double downcast
        
        let urlContained: Bool = hostWhiteList.contains(newHost)
        
        XCTAssertFalse(urlContained, "Expected the host whitelist to NOT contain the new host full URL we added")
        
        let hostContained: Bool = hostWhiteList.contains("www.pearson.com")
        
        XCTAssertTrue(hostContained, "Expected the host whitelist to contain the new host we added")
        
        XCTAssertEqual(hostWhiteList.count, 2, "Expected the host whitelist to have a count of 2...the default entry plus the new entry")
    }
    
    func testAddHostArrayToWhiteList() {
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        let newHosts: [String] = ["www.pearson.com", "www.pearsonmedia.com"]
        
        pxePlayerPageViewOptions.addHostArrayToWhiteList(newHosts)
        
        let hostWhiteList: [String] = pxePlayerPageViewOptions.hostWhiteList() as NSArray as! [String] //Double downcast
        print("hostWhiteList count: \(hostWhiteList.count)")
        let containsPearsonDotCom: Bool = hostWhiteList.contains("www.pearson.com")
        
        XCTAssertTrue(containsPearsonDotCom, "Expected the host whitelist to contain \"www.pearson.com\" from the array we added.")
        
        let containsPearsonMediaDotCom: Bool = hostWhiteList.contains("www.pearson.com")
        
        XCTAssertTrue(containsPearsonMediaDotCom, "Expected the host whitelist to contain \"www.pearsonmedia.com\"  from the array we added.")
        
        XCTAssertEqual(hostWhiteList.count, 3, "Expected the host whitelist to have a count of three...the default entry plus the two new entries")
    }
    
    func testAddHostToExternalListWithHost() {
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        let newHost = "www.pearson.com"
        
        pxePlayerPageViewOptions.addHostToExternalList(newHost)
        
        let hostExternalList: [String] = pxePlayerPageViewOptions.hostExternalList() as NSArray as! [String] //Double downcast
        
        let contained: Bool = hostExternalList.contains(newHost)
        
        XCTAssertTrue(contained, "Expected the host external list to contain the new host we added")
        
        XCTAssertEqual(hostExternalList.count, 1, "Expected the host  external list to have a count of 1...the new entry")
    }
    
    func testAddHostToExternalListWithURL() {
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        let newHost = "http://www.pearson.com/url"
        
        pxePlayerPageViewOptions.addHostToExternalList(newHost)
        
        let hostExternalList: [String] = pxePlayerPageViewOptions.hostExternalList() as NSArray as! [String] //Double downcast
        
        let urlContained: Bool = hostExternalList.contains(newHost)
        
        XCTAssertFalse(urlContained, "Expected the host external list to NOT contain the new host full URL we added")
        
        let hostContained: Bool = hostExternalList.contains("www.pearson.com")
        
        XCTAssertTrue(hostContained, "Expected the host external list to contain the new host we added")
        
        XCTAssertEqual(hostExternalList.count, 1, "Expected the host  external list to have a count of 1...the new entry")
    }
    
    func testAddHostArrayToExternalList() {
        
        let pxePlayerPageViewOptions: PxePlayerPageViewOptions = PxePlayerPageViewOptions()
        
        let newHosts: [String] = ["www.pearson.com", "www.pearsonmedia.com"]
        
        pxePlayerPageViewOptions.addHostArrayToExternalList(newHosts)
        
        let hostExternalList: [String] = pxePlayerPageViewOptions.hostExternalList() as NSArray as! [String] //Double downcast
        print("hostExternalList count: \(hostExternalList.count)")
        let containsPearsonDotCom: Bool = hostExternalList.contains("www.pearson.com")
        
        XCTAssertTrue(containsPearsonDotCom, "Expected the host external list to contain \"www.pearson.com\" from the array we added.")
        
        let containsPearsonMediaDotCom: Bool = hostExternalList.contains("www.pearson.com")
        
        XCTAssertTrue(containsPearsonMediaDotCom, "Expected the host external  list to contain \"www.pearsonmedia.com\"  from the array we added.")
        
        XCTAssertEqual(hostExternalList.count, 2, "Expected the host whitelist to have a count of 2...the two new entries")
    }
}
