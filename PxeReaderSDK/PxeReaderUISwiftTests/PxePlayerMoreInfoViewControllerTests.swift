//
//  PxePlayerMoreInfoViewControllerTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 11/23/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import UIKit
import XCTest

class PxePlayerMoreInfoViewControllerTests: XCTestCase, PXEPlayerMoreInfoDelegate {
    
    var moreInfoVC: PXEPlayerMoreInfoViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "PxeReaderStoryboard", bundle: NSBundle(forClass: self.dynamicType))
        moreInfoVC = storyboard.instantiateViewControllerWithIdentifier("MoreInfo") as! PXEPlayerMoreInfoViewController
        moreInfoVC.delegate = self;
        
        let moreInfo: [String:String] = [
            "description" : "A type of lipid commonly found in foods and the body; also known as fat. Triglycerides consist of three fatty acids attached to a glycerol backbone.",
            "key" : "P700049662200000000000000000B568",
            "method" : "glossary",
            "term" : "triglycerides",
            "type" : "onGlossaryData",
        ]
        print("MoreInfo: \(moreInfo)")
        
        moreInfoVC.jsonDict = moreInfo;
        
        let _ = moreInfoVC.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewSetCloseButtonVisibility()
    {
        let closeButtonHidden = moreInfoVC.closeButton!.hidden
        
        XCTAssertTrue(closeButtonHidden, "Close button should be hidden since the [UIDevice currentDevice].userInterfaceIdiom would be undefined")
    }
    
    func testViewSetTextValues()
    {
        let miTitle: String! = moreInfoVC.titleLabel?.text
        print("MoreInfo Title Label: \(miTitle)")
        print("MoreInfo JSONDict: \(moreInfoVC.jsonDict!)")
        
        XCTAssertEqual(miTitle, "triglycerides", "Title label text should be equal to termi from jsonDict")
    }
    
    func testViewWillAppear() {
        
        moreInfoVC.viewWillAppear(true)
        
        let miScreenName: String! = moreInfoVC.screenName
        
        XCTAssertEqual(miScreenName, "More Info", "Expected the screen name  to \"More Info\"")
    }
    
    func testWebViewShouldStartLoadWithRequestNavigationTypeLoadingBlankRequest() {
        
        let blankURL: NSURL = NSURL.init(string: "about:blank")!
        let blankRequest: NSURLRequest = NSURLRequest.init(URL: blankURL)
        
        let shouldLoad: Bool = moreInfoVC.webView(moreInfoVC.webView!, shouldStartLoadWithRequest: blankRequest, navigationType: UIWebViewNavigationType.LinkClicked)
        
        XCTAssertTrue(shouldLoad, "Expect an about:blank url request to load so that web view can be cleared")
    }
    
    func testWebViewShouldStartLoadWithRequestNavigationTypeLoadingNonBlankRequest() {
        
        let nonblankURL: NSURL = NSURL.init(string: "www.pearson.com")!
        let nonblankRequest: NSURLRequest = NSURLRequest.init(URL: nonblankURL)
        
        let shouldLoad: Bool = moreInfoVC.webView(moreInfoVC.webView!, shouldStartLoadWithRequest: nonblankRequest, navigationType: UIWebViewNavigationType.LinkClicked)
        
        XCTAssertFalse(shouldLoad, "Expect a nonblank request to NOT load in the More Info webView")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
