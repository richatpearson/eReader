//
//  PxePlayerParserTests.swift
//  PxeReader
//
//  Created by Tomack, Barry on 10/3/14.
//  Copyright (c) 2014 Pearson, Inc. All rights reserved.
//

import UIKit
import Foundation
import XCTest

class PxePlayerParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
    
    func testParseBookShelf()
    {
        let book1 = getBook1()
        let book2 = getBook2()
        var entries = [book1, book2];
        
        var bookshelfEntries = ["entries": entries]
        
        let parsedBookshelf = PxePlayerParser.parseBookShelf(bookshelfEntries)
        
        XCTAssertEqual(2, parsedBookshelf.books.count)
        
        let parsedBook1:PxePlayerBook = parsedBookshelf.books[0] as! PxePlayerBook
        let parsedBook2:PxePlayerBook = parsedBookshelf.books[1] as! PxePlayerBook
        
        let book1Title:String = book1["title"] as! String
        let book2Title:String = book2["title"] as! String
        XCTAssertEqual(book1Title, parsedBook1.title)
        XCTAssertEqual(book2Title, parsedBook2.title)
    }
    
    func testParseBookmark()
    {
        let bookmarksDict = getBookmarks() as NSDictionary
        var bookmarksArray: Array<NSDictionary> = bookmarksDict["bookmarks"] as! Array<NSDictionary>
        
        let parsedBookmarks:PxePlayerBookmarks = PxePlayerParser.parseBookmark(bookmarksDict as [NSObject : AnyObject])
        
        XCTAssertEqual(2, parsedBookmarks.bookmarks.count, "Not parsing bookmarks properly in parseBookmark");
        
        let bookmark1:Dictionary = bookmarksArray[0] as Dictionary;
        let bookmark2:Dictionary = bookmarksArray[1] as Dictionary;
        
        let parsedBookmark1:PxePlayerBookmark = parsedBookmarks.bookmarks[0] as! PxePlayerBookmark;
        let parsedBookmark2:PxePlayerBookmark = parsedBookmarks.bookmarks[1] as! PxePlayerBookmark;
        
        XCTAssertEqual(parsedBookmark1.bookmarkTitle, bookmark1["title"]! as! String, "Not parsing individual bookmarks properly in parseBookmarks")
        XCTAssertEqual(parsedBookmark2.bookmarkTitle, bookmark2["title"]! as! String, "Not parsing individual bookmarks properly in parseBookmarks")
        
        let contextId = parsedBookmarks.contextId;
        let identityId = parsedBookmarks.identityId;
        
        XCTAssertEqual(contextId, bookmarksDict["contextId"]! as! String, "Not parsing context Id properly in parseBookmark")
        XCTAssertEqual(identityId, bookmarksDict["identityId"]! as! String, "Not parsing identity Id properly in parseBookmark")
    }
    
    func testIsPageBookmarked()
    {
        var pageBookmarked = ["isBookmarked": "1"]
        
        let checkBookmarkTrue:PxePlayerCheckBookmark = PxePlayerParser.isPageBookmarked(pageBookmarked);
        XCTAssertEqual(checkBookmarkTrue.isBookmarked, true, "Not parsing isPageBookmarked as true properly")
        
        pageBookmarked = ["isBookmarked": "0"]
        
        let checkBookmarkFalse:PxePlayerCheckBookmark = PxePlayerParser.isPageBookmarked(pageBookmarked);
        XCTAssertEqual(checkBookmarkFalse.isBookmarked, false, "Not parsing isPageBookmarked as false properly")
    }
    
    func testParseAddBookmark()
    {
        let addBookmark = getAddEditBookmark() as NSDictionary
        let parseAddBookmark:PxePlayerAddBookmark = PxePlayerParser.parseAddBookmark(addBookmark as [NSObject : AnyObject]) as! PxePlayerAddBookmark
        
        let addBookmarkTitle: String = addBookmark["title"]! as! String
        let addBookmarkContextId = addBookmark["contextId"]! as! String
        let addBookmarkIdentityId = addBookmark["identityId"]! as! String
        let addBookmarkUri = addBookmark["uri"]! as! String
        
        XCTAssertEqual(parseAddBookmark.bookmarkTitle, addBookmarkTitle, "Not parsing parseAddBookmark properly: bookmarkTitle")
        XCTAssertEqual(parseAddBookmark.contextID, addBookmarkContextId, "Not parsing parseAddBookmark properly: contextId")
        XCTAssertEqual(parseAddBookmark.identityID, addBookmarkIdentityId, "Not parsing parseAddBookmark properly: contextId")
        XCTAssertEqual(parseAddBookmark.uri, addBookmarkUri, "Not parsing parseAddBookmark properly: contextId")
    }
    
    func testParseDeleteBookmark()
    {
        let deleteBookmark = getDeleteBookmark() as NSDictionary
        let parseDeleteBookmark:PxePlayerDeleteBookmark = PxePlayerParser.parseDeleteBookmark(deleteBookmark as [NSObject : AnyObject]) as! PxePlayerDeleteBookmark
        
        let deleteBookmarkContextId = deleteBookmark["contextId"]! as! String
        let deleteBookmarkIdentityId = deleteBookmark["identityId"]! as! String
        let deleteBookmarkUri = deleteBookmark["uri"]! as! String
        
        XCTAssertEqual(deleteBookmarkContextId, parseDeleteBookmark.contextID, "Not parsing parseDeleteBookmark properly: contextID")
        XCTAssertEqual(deleteBookmarkIdentityId, parseDeleteBookmark.identityID, "Not parsing parseDeleteBookmark properly: identityID")
        XCTAssertEqual(deleteBookmarkUri, parseDeleteBookmark.uri, "Not parsing parseDeleteBookmark properly: uri")
    }
    
    func testParseEditBookmark()
    {
        let editBookmark = getAddEditBookmark() as NSDictionary
        
        let parseEditBookmark:PxePlayerEditBookmark = PxePlayerParser.parseEditBookmark(editBookmark as [NSObject : AnyObject]) as! PxePlayerEditBookmark
        
        let editBookmarkTitle: String = editBookmark["title"]! as! String
        let editBookmarkUri = editBookmark["uri"]! as! String
        
        XCTAssertEqual(editBookmarkTitle, parseEditBookmark.bookmarkTitle, "Not parsing parseEditBookmark properly: bookmarkTitle")
        XCTAssertEqual(editBookmarkUri, parseEditBookmark.uri, "Not parsing parseEditBookmark properly: uri")
    }

// Utility functions
    func getBook1() -> NSDictionary
    {
        var book = ["active" : "1",
            "apiBookId": "61ac1af0-06af-11e4-9187-55aed373d571",
            "bookAssociationPrimaryUrl": "",
            "bookId": "YUZK48W6JZ",
            "coverImageUrl": "http://content.openclass.com/eps/pearson-reader/api/item/c5df9995-cb05-43ed-86e9-3324beaf06e9/1/file/demo_sample_ast_pxe_weidong_creature_deep_v1_sjg/OPS/xhtml/img/cover.jpg",
            "creator": "Jeri Cipriano",
            "date": "2013",
            "description": "Ingested by Steven Gagliostro (on 07-08-14)",
            "edition": "1",
            "expirationDate": "2016-08-01",
            "expired": "0",
            "expiringWithin": "665",
            "favorite": "0",
            "filename": "demo_sample_ast_pxe_weidong_creature_deep_v1_sjg.epub",
            "inWarningPeriod": "0",
            "indexId": "<null>",
            "isbn": "Not Available",
            "language": "en",
            "lastAccessTs": "2014-10-06 22:05:51",
            "opfBookId": "0-978-0328-47290_1",
            "publisher": "Pearson",
            "rights": "Not Available",
            "source": "local",
            "status": "PUBLISHED",
            "subject": "leveledreader",
            "thumbnailImageUrl": "http://content.openclass.com/eps/pearson-reader/api/item/c720620e-91f6-4e64-be57-0f4fd3a54e23/1/file/images/cover.jpg",
            "title": "DEMO SAMPLE - Creature of the Deep",
            "toc":  [
                "http://content.openclass.com/eps/pearson-reader/api/item/c5df9995-cb05-43ed-86e9-3324beaf06e9/1/file/demo_sample_ast_pxe_weidong_creature_deep_v1_sjg/OPS/toc.ncx",
                "http://content.openclass.com/eps/pearson-reader/api/item/c5df9995-cb05-43ed-86e9-3324beaf06e9/1/file/demo_sample_ast_pxe_weidong_creature_deep_v1_sjg/OPS/package.opf"
                ],
            "withAnnotations": "0"];
        
        return book
    }
    
    func getBook2() -> NSDictionary
    {
        var book = [
                "active": 1,
                "apiBookId": "cc792d00-36ed-11e4-a43a-7565b00a8dbf",
                "bookAssociationPrimaryUrl": "",
                "bookId": "1KFZ86LNEFN-REV",
                "coverImageUrl": "http://content.openclass.com/eps/pearson-reader/api/item/10dddec1-0efb-4068-9194-e1b88d0209b7/100/file/qatesting_0328516341_rdg14_anc_na_pxel_oth_noscript_v1_sjg/OPS/xhtml/img/0328516341_cover.jpg",
                "creator": "Johanna Biviano",
                "date": "2014",
                "description": "QA TESTING - America's National Parks",
                "edition": "100",
                "expirationDate":"2016-08-01",
                "expired": "0",
                "expiringWithin": "665",
                "favorite": "0",
                "filename": "qatesting_0328516341_rdg14_anc_na_pxel_oth_noscript_v1_sjg.epub",
                "inWarningPeriod": "0",
                "indexId": "37a6259cc0c1dae299a7866489dff0bd",
                "isbn": "Not Available",
                "language": "en",
                "lastAccessTs": "2014-10-06 22:05:32",
                "opfBookId": "0-328-51634-1",
                "publisher": "Pearson",
                "rights": "Copyright \\U00a92014",
                "source": "local",
                "status": "PUBLISHED",
                "subject": "Leveled Reader",
                "thumbnailImageUrl": "https://content.openclass.com/eps/pearson-reader/api/item/70687196-2e92-4847-89e9-af10e4124013/1/file/images/0328516341_cover.jpg",
                "title": "QA TESTING - America's National Parks",
                "toc": [
                        "http://content.openclass.com/eps/pearson-reader/api/item/10dddec1-0efb-4068-9194-e1b88d0209b7/100/file/qatesting_0328516341_rdg14_anc_na_pxel_oth_noscript_v1_sjg/OPS/toc.ncx",
                        "http://content.openclass.com/eps/pearson-reader/api/item/10dddec1-0efb-4068-9194-e1b88d0209b7/100/file/qatesting_0328516341_rdg14_anc_na_pxel_oth_noscript_v1_sjg/OPS/package.opf"
                        ],
                "withAnnotations": "0"];
        
        return book
    }
    
    func getBookmarks() -> NSDictionary
    {
        var bookMarks = [
            "contextId": "YR7HIWP620",
            "identityId": "nextextqa_edu",
            "bookmarks": [
                [
                    "createdTimestamp": "1410966321008",
                    "title": "Contents",
                    "uri": "xhtml/fileP7000478548000000000000000009C4A.xhtml#P7000478548000000000000000009C4A"
                ],
                [
                    "createdTimestamp": "1410991695687",
                    "title": "Other Marketing Titles",
                    "uri": "xhtml/filed6e151400.xhtml#d6e151400"
                ]
            ]
        ];
        return bookMarks
    }
    
    func getAddEditBookmark() -> NSDictionary
    {
        var addBookmark = [
            "contextId": "16ML3A5YRUN",
            "createdTimestamp": "1412711673368",
            "data": [
                "_timestamp": "1412711673368",
                "_title": "Objective 3",
                "_uri": "xhtml/fileP7000478548000000000000000009DC1.xhtml#P7000478548000000000000000009E93"
            ],
            "identityId": "nextext_qauser1",
            "title": "Objective 3",
            "uri": "xhtml/fileP7000478548000000000000000009DC1.xhtml#P7000478548000000000000000009E93"
        ];
        return addBookmark
    }
    
    func getDeleteBookmark() -> NSDictionary
    {
        var deleteBookmark = [
            "contextId": "16ML3A5YRUN",
            "createdTimestamp": "1412713252561",
            "identityId": "nextext_qauser1",
            "uri": "xhtml/fileP7000478548000000000000000009DC1.xhtml#P7000478548000000000000000009E93"
        ];
        return deleteBookmark
    }

