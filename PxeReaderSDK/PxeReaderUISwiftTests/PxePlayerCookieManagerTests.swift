//
//  PxePlayerCookieManagerTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/28/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxePlayerCookieManagerTests: XCTestCase {
    
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
                print("UpdatedDataInterface: \(success)")
            })
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetRequestHeaders() {
        let requestHeaders: Dictionary = PXEPlayerCookieManager.getRequestHeaders() as! [String : AnyObject]
        
        print("requestHeaders: \(requestHeaders)")
        XCTAssertEqual("\(self.dataInterface!.contentAuthTokenName)=\(self.dataInterface!.contentAuthToken)", (requestHeaders["Cookie"] as! String), "Contents of Cookie should be contentAuthTokenName=contentAuthToken")
    }
}
