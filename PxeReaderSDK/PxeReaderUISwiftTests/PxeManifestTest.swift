//
//  PxeManifestTest.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeManifestTest: CoreDataInMemoryStack {
    
    var pxeManifest:PxeManifest?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeManifest", inManagedObjectContext: self.managedObjectContext!)
        pxeManifest = PxeManifest(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeManifest = nil
        super.tearDown()
    }
    
    func testPxeManifest() {
        XCTAssertNotNil(self.pxeManifest, "unable to create PxeManifest")
    }
    
}
