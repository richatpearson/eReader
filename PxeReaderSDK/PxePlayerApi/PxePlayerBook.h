//
//  NTBook.h
//  NTApi
//
//  Created by Swamy Manju R on 02/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 A simple class to parse the book data downloaded from the server into the model
 */
@interface PxePlayerBook : NSObject

/**
 A NSString variable to hold the title of the book
 */
@property (nonatomic, strong) NSString  *title;

/**
 A NSString variable to hold the isbn of the book
 */
@property (nonatomic, strong) NSString  *isbn;

/**
 A NSString variable to hold the book edition
 */
@property (nonatomic, strong) NSString  *edition;

/**
 A NSString variable to hold the book cover url
 */
@property (nonatomic, strong) NSString  *coverUrl;

/**
 A NSString variable to hold the book thumbnail URL
 */
@property (nonatomic, strong) NSString  *thumbUrl;

/**
 A NSString to hold the user last access time stamp of the book
 */
@property (nonatomic, strong) NSString  *lastAccessTs;

/**
 A NSString variable to hold the book subscription expiration date
 */
@property (nonatomic, strong) NSString  *expirationDate;

/**
 A NSString variable to hold the book's copyright information
 */
@property (nonatomic, strong) NSString  *copyrightInfo;

/**
 A NSString variable to hold the book's subject
 */
@property (nonatomic, strong) NSString  *subject;

/**
 A NSString variable to hold the book's publisher details
 */
@property (nonatomic, strong) NSString  *publisher;

/**
 A NSString variable to hold the book's creator name
 */
@property (nonatomic, strong) NSString  *creator;

/**
 A NSString variable to hold the date information
 */
@property (nonatomic, strong) NSString  *date;

/**
 A NSString variable to hold the language information
 */
@property (nonatomic, strong) NSString  *language;

/**
 A NSString variable to hold the book's short descriptions
 */
@property (nonatomic, strong) NSString  *b_description;

/**
 A NSString variable to hold the book UUID
 */
@property (nonatomic, strong) NSString  *bookUUID;

/**
 A NSString variable to hold the book's author name
 */
@property (nonatomic, strong) NSString  *author;

/**
 A NSArray variable to hold the list of page URL's
 */
@property (nonatomic, strong) NSArray   *pageURLS;

/**
 A BOOL variable to check book subscription warning period
 */
@property (nonatomic, assign) BOOL      isWarningPeriod;

/**
 A BOOL variable to check book has expired
 */
@property (nonatomic, assign) BOOL      isExpired;

/**
 A BOOL variable to check the book has favourite
 */
@property (nonatomic, assign) BOOL      isFavorite;

/**
 A BOOL variable to check book has active
 */
@property (nonatomic, assign) BOOL      isActive;

/**
 A BOOL variable to check book has notes
 */
@property (nonatomic, assign) BOOL      withAnnotations;

/**
 A BOOL variable to check book is available to download
 */
@property (nonatomic, assign) BOOL      isDownloadable;
/**
 A Sting to hold the name of the offline epub
 */
@property (nonatomic, strong) NSString      *epubName;
/**
 A Sting to hold the url of the offline epub
 */
@property (nonatomic, strong) NSString      *epubURL;
/**
 A string to hold on to the indexId from services
 */
@property(nonatomic, strong) NSString *indexId;

@end
