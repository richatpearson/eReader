//
//  PxeURLProtocolTest.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/29/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeURLProtocolTest: XCTestCase {
    
    var dataInterface: PxePlayerDataInterface?
    
    override func setUp() {
        super.setUp()
        
        if((self.dataInterface == nil))
        {
            self.dataInterface = PxePlayerDataInterface()
            self.dataInterface!.identityId = "nexttext_qauser1"
            self.dataInterface!.contentAuthToken = "ST-4317-TF0dxzcSq7LLdVOLrbpd-b3-rumba-int-01-02"
            self.dataInterface?.contentAuthTokenName = "phonyContentAuthTokenName"
            self.dataInterface?.cookieDomain = "phonyCookieDomain"
            
            self.dataInterface?.masterPlaylist = [
                "https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_introduction.xhtml",
                "https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_01.xhtml",
                "https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/OPS/text/bookmatter-02/bkm2_sec_02.xhtml"
            ]
            self.dataInterface?.contextId = "1234567890"
            self.dataInterface?.afterCrossRefBehaviour = "continue"
            self.dataInterface?.onlineBaseURL = "https://content.openclass.com/eps/pearson-reader/api/item/5bb5e109-60cf-46d6-87f8-35b153f316e5/100/file/pearson_ciccarelli_v13/"
            
            let pxePlayer = PxePlayer.sharedInstance()
            pxePlayer.updateDataInterface(self.dataInterface, onComplete: { (success, error) -> () in
                print("UpdatedDataInterface Success: \(success)")
            })
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanInitWithRequest() {
        
        let request1URL = NSURL.init(string: "https://www.pearson.com/testURLProtocolwithHTTP")
        let urlRequest1:NSURLRequest = NSURLRequest.init(URL: request1URL!)
        
        XCTAssertFalse(PxeURLProtocol.canInitWithRequest(urlRequest1), "canInitWithRequest should return false for url with https")
        
        let request2URL = NSURL.init(string: "OPS/text/bookmatter-02/bkm2_sec_02.xhtml")
        let urlRequest2:NSURLRequest = NSURLRequest.init(URL: request2URL!)
        
        XCTAssertTrue(PxeURLProtocol.canInitWithRequest(urlRequest2), "canInitWithRequest should return true for relative path")
    }
    
    func testCanonicalRequestForRequest() {
        
        let urlString = "https://www.pearson.com/testURLProtocol"
        let requestURL = NSURL.init(string: urlString)
        let urlRequest:NSURLRequest = NSURLRequest.init(URL: requestURL!)
        
        let returnedURLString = PxeURLProtocol.canonicalRequestForRequest(urlRequest).URL?.absoluteString
        XCTAssertEqual(urlString, returnedURLString)
    }
    
    func testRequestIsCacheEquivalent() {
        
        let request1URL = NSURL.init(string: "https://www.pearson.com/testURLProtocolwithHTTP")
        let urlRequest1:NSURLRequest = NSURLRequest.init(URL: request1URL!)
        
        let request2URL = NSURL.init(string: "https://www.pearson.com/testURLProtocolwithHTTP")
        let urlRequest2:NSURLRequest = NSURLRequest.init(URL: request2URL!)
        
        XCTAssertTrue(PxeURLProtocol.requestIsCacheEquivalent(urlRequest1, toRequest: urlRequest2))
    }
}
