//
//  PxeCustomBasketDetailTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeCustomBasketDetailTests: CoreDataInMemoryStack {
    
    var pxeCustomBasketDetail:PxeCustomBasketDetail?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeCustomBasketDetail", inManagedObjectContext: self.managedObjectContext!)
        pxeCustomBasketDetail = PxeCustomBasketDetail(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeCustomBasketDetail = nil
        super.tearDown()
    }
    
    func testPxeCustomBasketDetail() {
        XCTAssertNotNil(self.pxeCustomBasketDetail, "unable to create PxeCustomBasketDetail")
    }
    
}
