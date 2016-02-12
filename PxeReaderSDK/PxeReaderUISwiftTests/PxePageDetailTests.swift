//
//  PxePageDetailTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxePageDetailTests: CoreDataInMemoryStack {
    
    var pxePageDetail:PxePageDetail?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxePageDetail", inManagedObjectContext: self.managedObjectContext!)
        pxePageDetail = PxePageDetail(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxePageDetail = nil
        super.tearDown()
    }
    
    func testPxePageDetail() {
        XCTAssertNotNil(self.pxePageDetail, "unable to create PxePageDetail")
    }
    
}
