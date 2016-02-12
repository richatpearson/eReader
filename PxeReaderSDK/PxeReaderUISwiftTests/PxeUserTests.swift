//
//  PxeUserTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class PxeUserTests: CoreDataInMemoryStack {
    
    var pxeUser:PxeUser?
    
    override func setUp() {
        super.setUp()
        let entity = NSEntityDescription.entityForName("PxeUser", inManagedObjectContext: self.managedObjectContext!)
        pxeUser = PxeUser(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.pxeUser = nil
        super.tearDown()
    }
    
    func testPxeUser() {
        XCTAssertNotNil(self.pxeUser, "unable to create PxeUser")
    }
        
}
