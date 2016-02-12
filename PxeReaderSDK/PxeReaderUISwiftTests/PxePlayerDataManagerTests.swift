//
//  PxePlayerDataManagerTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 11/4/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

import UIKit
import XCTest
import Foundation
import CoreData
import ObjectiveC

class PxePlayerDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        var dataAdded = false
        // Check if User is there, if not, add user, context and pages
        let userArray = getAllUsers()
        print("userArray: \(userArray)")
        if userArray != nil && userArray!.count > 0
        {
            print("ALL READY HAVE USERS: \(userArray!.count)\n\n")
            
            for pxeUser: PxeUser in userArray!
            {
                if (pxeUser.identity_id == "987654321")
                {
                    dataAdded = true
                    break;
                }
            }
        }
        
        if(dataAdded == false)
        {
            print("ADDING DATA FOR USERS CONTEXT AND PAGES\n\n")
            
            addData()
        }
    }
    
    override func tearDown() {
        
        deleteData()
        
        super.tearDown()
    }

// TEST METHODS //
    
    func testSharedInstance() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        XCTAssertNotNil(dataManager)
    }
    
    func testUniqueInstance() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager()
        
        XCTAssertNotNil(dataManager)
    }
    
    func testGetObjectContext() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let managedObjectContext = dataManager.getObjectContext()
        
        XCTAssertNotNil(managedObjectContext)
    }
    
    func testSave() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let pxeUser: PxeUser = NSEntityDescription.insertNewObjectForEntityForName("PxeUser", inManagedObjectContext: dataManager.getObjectContext()) as! PxeUser
        pxeUser.identity_id = "123456789"
        
        if ( dataManager.save() ) {
            XCTAssertFalse(dataManager.getObjectContext().hasChanges, "All changes should have been saved")
        }
        
    }
    
    func testFetchEntityForModelWithValue() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        if let userArray = dataManager.fetchEntity("identity_id", forModel: "PxeUser", withValue: "987654321") {
            XCTAssertEqual(userArray.count, 1)
        }
    }
    
    func testFetchEntityForModelWithValueAndKeyResultTypeWithSortKeyAndAscending () {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results: Dictionary = dataManager.fetchEntity("pageURL", forModel: "PxePageDetail", withValue: "Page 2", andKey: "pageTitle", resultType: NSFetchRequestResultType.DictionaryResultType.rawValue, withSortKey: "pageNumber", andAscending: true) as! [String : AnyObject]
        
        XCTAssertEqual((results["pageURL"] as! String), "OPS/page2.xhtml")
        
    }
    
    func testFetchEntitiesForModelWithSortKeyAscendingWithPredicateFetchLimitResultType() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let predicate = NSPredicate(format: "context.context_id == \"ABCDEFG\"")
        
        let results: Array = dataManager.fetchEntitiesForModel("PxePageDetail", withSortKey: "pageTitle", ascending: false, withPredicate: predicate, fetchLimit: 3, resultType: NSFetchRequestResultType.ManagedObjectResultType.rawValue)
        
        print("results: \(results)")
        
        XCTAssertEqual(results.count, 3)
    }
    
    func testFetchEntityForContextIdForModelWithValue() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results: Dictionary = dataManager.fetchEntity("pageURL", forContextId: "ABCDEFG", forModel: "PxePageDetail", withValue: "OPS/page2.xhtml") as! [String : AnyObject]
            
        print("results: \(results)")
        let pageTitle: String = results["pageTitle"]! as! String
        print("pageTitle: \(pageTitle)")
        XCTAssertEqual(pageTitle, "Page 2")
    }

    func testFetchEntityForContextIdForModelWithValueResultTypeWithSortKeyAndAscending() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results: Dictionary = dataManager.fetchEntity("pageURL", forContextId: "ABCDEFG", forModel: "PxePageDetail", withValue: "OPS/page1.xhtml", resultType:NSFetchRequestResultType.DictionaryResultType.rawValue, withSortKey:nil, andAscending:false) as! [String : AnyObject]
        
        print("results: \(results)")
        let pageTitle: String = results["pageTitle"]! as! String
        print("pageTitle: \(pageTitle)")
        XCTAssertEqual(pageTitle, "Page 1")
    }
    
    func testFetchEntityForContextIdForModelContainingValue() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results: Dictionary = dataManager.fetchEntity("pageURL", forContextId: "ABCDEFG", forModel: "PxePageDetail", containingValue: "page1.xhtml") as! [String : AnyObject]
        
        print("results: \(results)")
        let pageTitle: String = results["pageTitle"]! as! String
        print("pageTitle: \(pageTitle)")
        XCTAssertEqual(pageTitle, "Page 1")
    }
    
    func testFetchEntitiesForModelWithPredicateResultTypeWithSortKeyAndAscendingFetchLimitAndGroupBy () {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let predicate = NSPredicate(format: "context.context_id == \"ABCDEFG\"")
        
        let results = dataManager.fetchEntities(["pageId", "pageURL", "parentId"], forModel: "PxePageDetail", withPredicate: predicate, resultType: NSFetchRequestResultType.DictionaryResultType.rawValue, withSortKey: "pageId", andAscending: false, fetchLimit: 0, andGroupBy: ["parentId"])

        print("results: \(results)")

        XCTAssertEqual(results.count, 1)
    }
    
    func testFetchEntityForModelWithPredicateWithSortKeyAndAscending() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let predicate = NSPredicate(format: "context.context_id == \"ABCDEFG\" AND pageId == \"11111\"")
        
        let results = dataManager.fetchEntity(["pageId", "pageURL", "parentId"], forModel: "PxePageDetail", withPredicate: predicate, withSortKey: "pageId", andAscending: true)
        print("results: \(results)")
        
        XCTAssertEqual(results["pageURL"], "OPS/page1.xhtml")
    }
    
    func testFetchEntityForModelWithValueResultTypeWithSortKeyAndAscending() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results = dataManager.fetchEntity("pageNumber", forModel: "PxePageDetail", withValue: "ABCDEFG", andKey: "context.context_id", withSortKey: "pageNumber", andAscending: false)
        print("\(__FUNCTION__) results: \(results)")
        
        XCTAssertEqual(results["pageNumber"], 3)
    }
    
    func testFetchMaxValuePropertyForContextIdReturnsMax() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results = dataManager.fetchMaxValue("PxePageDetail", property: "pageNumber", forContextId: "ABCDEFG")
        
        XCTAssertEqual(results, 3)
    }
    
    func testFetchMaxValuePropertyForContextIdGeneratesError() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager()
        
        let results = dataManager.fetchMaxValue("PxePageDetail", property: "pageNumber", forContextId: nil)
        
        XCTAssertEqual(results, 0, "Expecting 0 pages for a nil context id")
    }
    
    func testFetchCountPropertyForContextId() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results = dataManager.fetchCount("PxePageDetail", property: "pageId", forContextId: "ABCDEFG")

        XCTAssertEqual(results, 3, "Expecting 3 pages to have been added before test ran. Check that user Identity Id is 987654321")
    }
    
    func testFetchTOCTreeForContextId() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results = dataManager.fetchTocTree("root", forContextId: "ABCDEFG")
        
        XCTAssertEqual(results.count, 3, "Expecting 3 pages in the TOC for contextId: ABCDEFG")
    }
    
    func testFetchGlossaryForContextId() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results = dataManager.fetchGlossaryforContextId("ABCDEFG")
        
        XCTAssertEqual(results.count, 2, "Expecting 2 Glossary terms")
    }
    
    func testGetAssetForPage() {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let results = dataManager.getAssetForPage("OPS/page2.xhtml", contextId: "ABCDEFG")
        
        XCTAssertEqual("ABCDEFG5", results, "Expected the asset Id for the page2 but got \(results)")
    }


// UTILITY METHODS //
    
    func addData()
    {
        print("\(__FUNCTION__)")
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        // User
        let pxeUser: PxeUser = NSEntityDescription.insertNewObjectForEntityForName("PxeUser", inManagedObjectContext: dataManager.getObjectContext()) as! PxeUser
        pxeUser.identity_id = "987654321"
        
        // Context
        let pxeContext = NSEntityDescription.insertNewObjectForEntityForName("PxeContext", inManagedObjectContext: dataManager.getObjectContext()) as! PxeContext
        pxeContext.context_base_url = "http://pxe-sdk-test.com/testcontext/"
        pxeContext.context_id = "ABCDEFG"
        pxeContext.search_index_id = "searchIndexId123"
        pxeContext.toc_url = "http://pxe-sdk-test.com/testcontext/OPS/toc.xhtml"
        pxeContext.user = pxeUser
        
        // Pages
        let pxePageDetail1 = NSEntityDescription.insertNewObjectForEntityForName("PxePageDetail", inManagedObjectContext: dataManager.getObjectContext()) as! PxePageDetail
        pxePageDetail1.pageNumber = 1
        pxePageDetail1.context = pxeContext
        pxePageDetail1.pageId = "11111"
        pxePageDetail1.pageTitle = "Page 1"
        pxePageDetail1.pageURL = "OPS/page1.xhtml"
        pxePageDetail1.parentId = "root"
        pxePageDetail1.assetId = "ABCDEFG1"
        
        let pxePageDetail2 = NSEntityDescription.insertNewObjectForEntityForName("PxePageDetail", inManagedObjectContext: dataManager.getObjectContext()) as! PxePageDetail
        pxePageDetail2.pageNumber = 2
        pxePageDetail2.context = pxeContext
        pxePageDetail2.pageId = "11112"
        pxePageDetail2.pageTitle = "Page 2"
        pxePageDetail2.pageURL = "OPS/page2.xhtml"
        pxePageDetail2.parentId = "root"
        pxePageDetail2.assetId = "ABCDEFG5"
        
        let pxePageDetail3 = NSEntityDescription.insertNewObjectForEntityForName("PxePageDetail", inManagedObjectContext: dataManager.getObjectContext()) as! PxePageDetail
        pxePageDetail3.pageNumber = 3
        pxePageDetail3.context = pxeContext
        pxePageDetail3.pageId = "11113"
        pxePageDetail3.pageTitle = "Page 3"
        pxePageDetail3.pageURL = "OPS/page3.xhtml"
        pxePageDetail3.parentId = "root"
        pxePageDetail3.assetId = "ABCDEFG8"
        
        print("\(__FUNCTION__) ADDED 3 PAGES")
        
        // Glossary
        let pxeGlossary1 = NSEntityDescription.insertNewObjectForEntityForName("PxeGlossary", inManagedObjectContext: dataManager.getObjectContext()) as! PxeGlossary
        pxeGlossary1.key = "key1"
        pxeGlossary1.term = "term1"
        pxeGlossary1.definition = "definition1"
        pxeGlossary1.context = pxeContext

        let pxeGlossary2 = NSEntityDescription.insertNewObjectForEntityForName("PxeGlossary", inManagedObjectContext: dataManager.getObjectContext()) as! PxeGlossary
        pxeGlossary2.key = "key2"
        pxeGlossary2.term = "term2"
        pxeGlossary2.definition = "definition2"
        pxeGlossary2.context = pxeContext
        
        do {
            try dataManager.getObjectContext()!.save()
        } catch {
            print("Unresolved error trying to save user")
        }
        
        print("SAVED PAGES: \(getAllPages()!)")
    }
    
    func getAllUsers() -> [PxeUser]?
    {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("PxeUser", inManagedObjectContext: dataManager.getObjectContext())
        
        do {
            let results: [PxeUser]! = try dataManager.getObjectContext().executeFetchRequest(fetchRequest) as! [PxeUser]
            return results
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return nil
    }
    
    
    func getAllContexts() -> [PxeContext]?
    {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("PxeContext", inManagedObjectContext: dataManager.getObjectContext())
        fetchRequest.predicate = NSPredicate(format: "user.identity_id == \"987654321\"")
        
        do {
            let results: [PxeContext]! = try dataManager.getObjectContext().executeFetchRequest(fetchRequest) as! [PxeContext]
            return results
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return nil
    }
    
    func getAllPages() -> [PxePageDetail]?
    {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("PxePageDetail", inManagedObjectContext: dataManager.getObjectContext())
        
        do {
            let results: [PxePageDetail]! = try dataManager.getObjectContext().executeFetchRequest(fetchRequest) as! [PxePageDetail]
            return results
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return nil
    }
    
    func getAllGlossary() -> [PxeGlossary]?
    {
        let dataManager: PxePlayerDataManager = PxePlayerDataManager.sharedInstance()
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("PxeGlossary", inManagedObjectContext: dataManager.getObjectContext())
        
        do {
            let results: [PxeGlossary]! = try dataManager.getObjectContext().executeFetchRequest(fetchRequest) as! [PxeGlossary]
            return results
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return nil
    }
    
    func deleteData()
    {
        deleteAllUsers()
        deleteAllContexts()
        deleteAllPages()
        deleteAllGlossary()
    }
    
    func deleteAllUsers()
    {
        print("DELETING ALL USERS")
        let dataManager: PxePlayerDataManager = PxePlayerDataManager()
        // User
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("PxeUser", inManagedObjectContext: dataManager.getObjectContext())
        fetchRequest.predicate = NSPredicate(format: "identity_id == \"987654321\"")
        
        do {
            let results: [PxeUser] = try dataManager.getObjectContext().executeFetchRequest(fetchRequest) as! [PxeUser]
            
            for pxeUser: PxeUser in results {
                dataManager.getObjectContext().deleteObject(pxeUser)
            }
            
            do {
                try dataManager.getObjectContext()!.save()
            } catch {
                print("Unresolved error trying to delete users")
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func deleteAllContexts()
    {
        print("DELETING ALL CONTEXTS")
        let dataManager: PxePlayerDataManager = PxePlayerDataManager()
        // User
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("PxeContext", inManagedObjectContext: dataManager.getObjectContext())
        fetchRequest.predicate = NSPredicate(format: "user.identity_id == \"987654321\"")
        
        do {
            let results: [PxeContext] = try dataManager.getObjectContext().executeFetchRequest(fetchRequest) as! [PxeContext]
            
            for pxeContext: PxeContext in results {
                dataManager.getObjectContext().deleteObject(pxeContext)
            }
            
            do {
                try dataManager.getObjectContext()!.save()
            } catch {
                print("Unresolved error trying to delete context")
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func deleteAllPages()
    {
        print("DELETING ALL PAGES")
        let dataManager: PxePlayerDataManager = PxePlayerDataManager()
        // User
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("PxePageDetail", inManagedObjectContext: dataManager.getObjectContext())
        fetchRequest.predicate = NSPredicate(format: "context.user.identity_id == \"987654321\"")
        
        do {
            let results: [PxePageDetail] = try dataManager.getObjectContext().executeFetchRequest(fetchRequest) as! [PxePageDetail]
            
            for pxePageDetail: PxePageDetail in results {
                dataManager.getObjectContext().deleteObject(pxePageDetail)
            }
            
            do {
                try dataManager.getObjectContext()!.save()
            } catch {
                print("Unresolved error trying to delete pages")
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func deleteAllGlossary()
    {
        print("DELETING ALL GLOSSARY ENTRIES")
        let dataManager: PxePlayerDataManager = PxePlayerDataManager()
        // User
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("PxeGlossary", inManagedObjectContext: dataManager.getObjectContext())
        fetchRequest.predicate = NSPredicate(format: "context.user.identity_id == \"987654321\"")
        
        do {
            let results: [PxeGlossary] = try dataManager.getObjectContext().executeFetchRequest(fetchRequest) as! [PxeGlossary]
            
            for pxeGlossary: PxeGlossary in results {
                dataManager.getObjectContext().deleteObject(pxeGlossary)
            }
            
            do {
                try dataManager.getObjectContext()!.save()
            } catch {
                print("Unresolved error trying to delete glossary")
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
}