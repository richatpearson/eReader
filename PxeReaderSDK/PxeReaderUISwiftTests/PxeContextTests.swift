//
//  PxeContextTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeContextTests: CoreDataInMemoryStack {
    
    var pxeContext:PxeContext?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeContext", inManagedObjectContext: self.managedObjectContext!)
        pxeContext = PxeContext(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeContext = nil
        super.tearDown()
    }
    
    func testPxeContext() {
        XCTAssertNotNil(self.pxeContext, "unable to create PxeContext")
    }
    
}
