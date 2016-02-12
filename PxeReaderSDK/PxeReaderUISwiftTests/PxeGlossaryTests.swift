//
//  PxeGlossaryTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeGlossaryTests: CoreDataInMemoryStack {
    
    var pxeGlossary:PxeGlossary?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeGlossary", inManagedObjectContext: self.managedObjectContext!)
        pxeGlossary = PxeGlossary(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeGlossary = nil
        super.tearDown()
    }
    
    func testPxeGlossary() {
        XCTAssertNotNil(self.pxeGlossary, "unable to create PxeGlossary")
    }
    
}
