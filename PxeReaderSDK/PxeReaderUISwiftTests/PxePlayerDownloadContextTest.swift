//
//  PxePlayerDownloadContextTest.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/29/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxePlayerDownloadContextTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithFileTitleDownloadSourceContextIdAssetIdOnlineBaseUrlWithoutAssetId() {
        let downloadContext = PxePlayerDownloadContext.init(fileTitle: "Test File Title", downloadSource: "https://www.pearson.com/fileSource", contextId: "12345678", assetId: nil, onlineBaseUrl: "https://www.pearson.com/testBook");
        
        XCTAssertNotNil(downloadContext)
        
        XCTAssertEqual(downloadContext!.fileTitle, "Test File Title")
        XCTAssertEqual(downloadContext!.downloadSource, "https://www.pearson.com/fileSource")
        XCTAssertEqual(downloadContext!.contextId, "12345678")
        XCTAssertEqual(downloadContext!.assetId, "12345678")
        XCTAssertEqual(downloadContext!.onlineBaseUrl, "https://www.pearson.com/testBook")
    }
    
    func testInitWithFileTitleDownloadSourceContextIdAssetIdOnlineBaseUrlWithAssetId() {
        let downloadContext = PxePlayerDownloadContext.init(fileTitle: "Test File Title", downloadSource: "https://www.pearson.com/fileSource", contextId: "12345678", assetId: "987654321", onlineBaseUrl: "https://www.pearson.com/testBook");
        
        XCTAssertNotNil(downloadContext)
        
        
        XCTAssertEqual(downloadContext!.fileTitle, "Test File Title")
        XCTAssertEqual(downloadContext!.downloadSource, "https://www.pearson.com/fileSource")
        XCTAssertEqual(downloadContext!.contextId, "12345678")
        XCTAssertEqual(downloadContext!.assetId, "987654321")
        XCTAssertEqual(downloadContext!.onlineBaseUrl, "https://www.pearson.com/testBook")
    }
}
