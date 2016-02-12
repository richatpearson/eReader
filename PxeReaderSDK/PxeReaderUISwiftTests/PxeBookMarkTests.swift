//
//  PxeBookMarkTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeBookMarkTests: CoreDataInMemoryStack {
    
    var pxeBookMark:PxeBookMark?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeBookMark", inManagedObjectContext: self.managedObjectContext!)
        pxeBookMark = PxeBookMark(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeBookMark = nil
        super.tearDown()
    }
    
    func testPxeBookMark() {
        XCTAssertNotNil(self.pxeBookMark, "unable to create PxeBookMark")
    }
    
}
