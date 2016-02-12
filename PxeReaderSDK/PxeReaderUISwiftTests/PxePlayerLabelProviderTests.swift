//
//  PxePlayerLabelProviderTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/29/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxePlayerLabelProviderTests: XCTestCase, PxePlayerLabelProviderDelegate {
    
    var labelProvider:PxePlayerLabelProvider?
    
    override func setUp() {
        super.setUp()
        
        if(self.labelProvider == nil)
        {
            self.labelProvider = PxePlayerLabelProvider.init(delegate: self)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithDelegate() {
        
        XCTAssertNotNil(self.labelProvider, "unable to create instance of PxePlayerLabelProvider")
    }
    
    func testGetLabelForPageWithPath() {
        let relativePath = "OPS/relativePath.xhtml"
        
        let label: String! = self.labelProvider!.getLabelForPageWithPath(relativePath)
        
        XCTAssertEqual(label, "{\"pageTitle\":\"Test Page\",\"pageURL\":\"\(relativePath)\"}", "Not getting label provided by assigend delegate")
    }
    
    func provideLabelForPageWithPath(relativePath: String) -> String
    {
        let label: String = "{\"pageTitle\":\"Test Page\",\"pageURL\":\"\(relativePath)\"}"
        
        return label
    }
    
}
