//
//  PxePlayerLightBoxViewCotnrollerTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 1/4/16.
//  Copyright © 2016 Pearson. All rights reserved.
//

import XCTest

class PxePlayerLightBoxViewControllerTests: XCTestCase, PxePlayerLightboxDelegate {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitAsLightbox() {
        
        let lightBox: PxePlayerLightBoxViewController = getLightboxAsLightbox()
        
        XCTAssertNotNil(lightBox, "Expected to instantiate a PxePlayerLightBoxViewController")
    }
    
    func testInitAsBrowser() {
        
        let lightBox: PxePlayerLightBoxViewController = getLightboxAsBrowser()
        
        XCTAssertNotNil(lightBox, "Expected to instantiate a PxePlayerLightBoxViewController")
    }
    
    func testViewDidLoad() {
        
        let lightBox: PxePlayerLightBoxViewController = getLightboxAsLightbox()
        
        lightBox.viewDidLoad()
        
        let wView: UIWebView? = lightBox.getLightBoxWebView()
        XCTAssertNotNil(wView?.delegate, "Expected the webview delegate to be set on viewDidLoad")
        
        let progressView: UIProgressView? = lightBox.getProgressView()
        let isHidden: Bool = progressView!.hidden
        XCTAssertTrue(isHidden, "Expected progressView to be hidden on viewDidLoad")
    }
    
    func testViewWillAppearAsLightbox() {
        
        let lightBox: PxePlayerLightBoxViewController = getLightboxAsLightbox()
        
        lightBox.viewWillAppear(true)
        
        XCTAssertTrue(lightBox.lightBoxConfigured, "Expected Lightbox to be configured for viewWillAppear")
    }
    
    func testViewWillAppearAsBrowser() {
        
        let lightBox: PxePlayerLightBoxViewController = getLightboxAsBrowser()
        
        lightBox.viewWillAppear(true)
        
        XCTAssertTrue(lightBox.lightBoxConfigured, "Expected Lightbox to be configured for viewWillAppear")
    }
    
    

    
    // Lightbox delegate method
    func lightboxDidClose() {
        
        
    }
    
    // Lightbox GETs
    func getLightboxAsLightbox() ->PxePlayerLightBoxViewController {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "PxeReaderStoryboard", bundle: NSBundle(forClass: self.dynamicType))
        
        let contentURL = "OPS/relativeURL/page.xhtml"
            
        // Only open one instance of lightbox
        let lightBoxVC: PxePlayerLightBoxViewController = storyboard.instantiateViewControllerWithIdentifier("LIGHTBOX") as! PxePlayerLightBoxViewController
        
        lightBoxVC.isLightbox = true
        lightBoxVC.boxInfo = ["type":"gadget", "contentURL":contentURL, "fileType":"image"]
        lightBoxVC.delegate = self
        lightBoxVC.bundlePath = "\(NSBundle(forClass: self.dynamicType).bundlePath)/PxeReaderResources.bundle"
        
        let _ = lightBoxVC.view
        
        return lightBoxVC
    }
    
    func getLightboxAsBrowser() ->PxePlayerLightBoxViewController {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "PxeReaderStoryboard", bundle: NSBundle(forClass: self.dynamicType))
        
        let contentURL = "http://www.pearson.com/link/OPS/relativeURL/page.xhtml"
        
        // Only open one instance of lightbox
        let lightBoxVC: PxePlayerLightBoxViewController = storyboard.instantiateViewControllerWithIdentifier("LIGHTBOX") as! PxePlayerLightBoxViewController
        
        lightBoxVC.isLightbox = false
        lightBoxVC.boxInfo = ["type":"gadget", "contentURL":contentURL, "fileType":"link"]
        lightBoxVC.delegate = self
        lightBoxVC.bundlePath = "\(NSBundle(forClass: self.dynamicType).bundlePath)/PxeReaderResources.bundle"
        
        let _ = lightBoxVC.view
        
        return lightBoxVC
    }
}
