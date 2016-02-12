//
//  PxePlayer_Tests.m
//  PxeReader
//
//  Created by Tomack, Barry on 9/24/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

#import "PxePlayer.h"
#import "PxePlayerDataInterface.h"

@interface PxePlayer_Tests : XCTestCase

@property (strong, nonatomic) PxePlayerDataInterface *dataInterface;

@end

@implementation PxePlayer_Tests

- (void)setUp {
    [super setUp];
    
    self.dataInterface = [[PxePlayerDataInterface alloc] init];
    self.dataInterface.userName = @"unitTest";
    self.dataInterface.contextId = @"123456";
    self.dataInterface.userId = @"unitTest";
    
    self.dataInterface.learningContext = @"learningContentString";
    
    self.dataInterface.authToken = @"authToken:123456";
    self.dataInterface.afterCrossRefBehaviour = @"continue";
    self.dataInterface.bookPageTheme = @"default";
    self.dataInterface.bookPageFontSize = 14;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testPxePlayerSharedInstance {
    PxePlayer *pxePlayer = [PxePlayer sharedInstance];
    
    XCTAssertTrue(pxePlayer, @"Not able to access shared instance of PxePlayer!");
}

- (void) testPxePlayerUpdateDataInterface {
    
    XCTestExpectation *updateInterfaceExpectation = [self expectationWithDescription:@"interface updated"];
    
    [[PxePlayer sharedInstance] updateDataInterface:self.dataInterface finished:^(BOOL success){
        // Should fail since there's no ncx or master playlist
        XCTAssertFalse(success);
        
        [updateInterfaceExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        NSLog(@"UPDATEINTERFACEERROR: %@", error);
    }];
}

- (void) testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
