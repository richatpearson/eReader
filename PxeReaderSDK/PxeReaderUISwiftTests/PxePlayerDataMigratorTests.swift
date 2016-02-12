//
//  PxePlayerDataMigratorTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import UIKit
import XCTest
import Foundation
import CoreData

class PxePlayerDataMigratorTests: CoreDataInMemoryStack {
    
    var pxePlayerDataMigrator: PxePlayerDataMigrator?
    
    override func setUp() {
        super.setUp()
        pxePlayerDataMigrator = PxePlayerDataMigrator()
    }
    
    override func tearDown() {
        self.pxePlayerDataMigrator = nil
        super.tearDown()
    }
    
    func testPxePlayerDataMigrator() {
        XCTAssertNotNil(self.pxePlayerDataMigrator, "unable to create PxePlayerDataMigrator")
    }
    
    func testMigrateDataForContextOnComplete() {

        let expectation = expectationWithDescription("Expecting to receive a \"No Data Migration necessary\" message")
        
        self.pxePlayerDataMigrator!.migrateDataForContext(self.managedObjectContext, onComplete: { (results, error) -> () in
        
            if ((error) != nil) {
                print("Error testing migrateDataForContext:onComplete:")
                XCTFail("FAILURE migrating DataForContext")
            } else {
                print("MIGRATION UNIT TEST SUCCESSFUL: \(results)")
                XCTAssertEqual("No Data Migration necessary", results)
            }
            
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5) { error in
            
            XCTAssertNil(error, "Something went horribly wrong")
        }
        
    }
}
