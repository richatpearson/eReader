//
//  PxeAnnotationsTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeAnnotationsTests: CoreDataInMemoryStack {
    
    var pxeAnnotations:PxeAnnotations?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeAnnotations", inManagedObjectContext: self.managedObjectContext!)
        pxeAnnotations = PxeAnnotations(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeAnnotations = nil
        super.tearDown()
    }
    
    func testPxeAnnotations() {
        XCTAssertNotNil(self.pxeAnnotations, "unable to create PxeAnnotations")
    }
}
