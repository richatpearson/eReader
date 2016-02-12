//
//  PxeAnnotationTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeAnnotationTests: CoreDataInMemoryStack {
    
    var pxeAnnotation:PxeAnnotation?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeAnnotation", inManagedObjectContext: self.managedObjectContext!)
        pxeAnnotation = PxeAnnotation(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeAnnotation = nil
        super.tearDown()
    }
    
    func testPxeAnnotation() {
        XCTAssertNotNil(self.pxeAnnotation, "unable to create PxeAnnotation")
    }
    
}
