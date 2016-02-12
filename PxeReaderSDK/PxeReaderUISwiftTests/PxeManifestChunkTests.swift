//
//  PxeManifestChunkTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeManifestChunkTests: CoreDataInMemoryStack {
    
    var pxeManifestChunk:PxeManifestChunk?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeManifestChunk", inManagedObjectContext: self.managedObjectContext!)
        pxeManifestChunk = PxeManifestChunk(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)

    }
    
    override func tearDown() {
        self.pxeManifestChunk = nil
        super.tearDown()
    }
    
    func testPxeManifestChunk() {
        XCTAssertNotNil(self.pxeManifestChunk, "unable to create PxeManifestChunk")
    }
    
}
