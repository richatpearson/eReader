//
//  CoreDataInMemoryStack.swift
//  PxeReader
//
//  Created by Tomack, Barry on 12/14/15.
//  Copyright © 2015 Pearson. All rights reserved.
//

import XCTest

class CoreDataInMemoryStack: XCTestCase {
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let testBundle = NSBundle(forClass: self.dynamicType)
        print("testBundle: \(testBundle)")
        let mom = NSManagedObjectModel.mergedModelFromBundles([testBundle])!
        
        return mom
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        print("urls: \(urls)")
        let storeURL = (urls[urls.endIndex-1]).URLByAppendingPathComponent(kDataBundleName + ".sqlite")
        print("storeURL: \(storeURL)")
        do {
            var store = try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            abort()
        }
        
        return psc
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        let psc = self.persistentStoreCoordinator
        if psc == nil {
            return nil
        }
        
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        
        managedObjectContext = nil
    }
}
