//
//  NTChapter.h
//  NTApi
//
//  Created by Saro Bear on 04/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the book chapter data into the model
 */
@interface PxePlayerChapter : NSObject

/**
 A NSString variable to hold the chapter UUID
 */
@property (nonatomic, strong) NSString  *chapterUUID;

/**
 A NSString variable to hold the title of the chapter
 */
@property (nonatomic, strong) NSString  *title;

/**
 A NSString variable to hold the front matter of the chapter
 */
@property (nonatomic, strong) NSString  *frontMatter;

/**
 A NSString variable to hold the back matter of the chapter
 */
@property (nonatomic, strong) NSString  *backMatter;

/**
 A NSString variable to hold the page UUID's of the chapter
 */
@property (nonatomic, strong) NSString  *pageUUIDS;

@end
