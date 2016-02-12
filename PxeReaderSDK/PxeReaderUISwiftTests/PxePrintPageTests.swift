//
//  PxePrintPageTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxePrintPageTests: CoreDataInMemoryStack {
    
    var pxePrintPage:PxePrintPage?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxePrintPage", inManagedObjectContext: self.managedObjectContext!)
        pxePrintPage = PxePrintPage(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxePrintPage = nil
        super.tearDown()
    }
    
    func testPxePrintPage() {
        XCTAssertNotNil(self.pxePrintPage, "unable to create PxePrintPage")
    }
}
