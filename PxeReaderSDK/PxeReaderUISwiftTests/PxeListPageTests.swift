//
//  PxeListPageTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeListPageTests: CoreDataInMemoryStack {
    
    var pxeListPage:PxeListPage?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeListPage", inManagedObjectContext: self.managedObjectContext!)
        pxeListPage = PxeListPage(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeListPage = nil
        super.tearDown()
    }
    
    func testExample() {
        XCTAssertNotNil(self.pxeListPage, "unable to create PxeListPage")
    }
    
}
