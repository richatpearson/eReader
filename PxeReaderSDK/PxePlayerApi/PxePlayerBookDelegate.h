//
//  PxePlayerBookDelegate.h
//  PxePlayerApi
//
//  Created by Saro Bear on 11/09/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


/**
 A informal protocol to which send's the book view controller to update or perform actions
 @Extension <NSObject>, extented from NSObject
 */
@protocol PxePlayerBookDelegate <NSObject>

@required

/**
 This method would be called to get the user auth token 
 @return NSString, returns the auth token as a string
 */
-(NSString*)getAuthToken;

/**
 This method would be called to get the user id
 @return NSString, returns the user id as a string
 */
-(NSString*)getUserId;

/**
 This method would be called to get the user book id
 @return NSString, returns the book id as a string
 */
-(NSString*)getBookId;

@optional

/**
 This method would be called to get the user course id
 @return NSString, returns the course id as a string
 */
-(NSString*)getCourseId;

/**
 This method would be called to get the toc url
 @return NSString, returns the toc url as a string
 */
-(NSString*)getTocURL;

/**
 This method would be called to check whether page with correspoding relative URL found in the core data
 @param NSString, relativeURL is a relative url of the page
 @return BOOL, returns the true if page found for the given relative url else returns false.
 */
-(BOOL)isPageAvailable:(NSString*)relativeURL;

/**
 This method would be called to load the page with it's relative URL
 @param NSString, relativeURL is a relative url of the page
 @return BOOL, returns the true if page has been loaded successfully else returns false.
 */
-(BOOL)loadPageWithRelativeURL:(NSString*)relativeURL;

/**
 This method would be called to load the page with it's relative URL with highlighting the book
 @param NSString, relativeURL is a relative url of the page
 @param NSArray, highlights is a 
 @return BOOL, returns the true if page has been loaded successfully else returns false.
 */
-(void)loadPageWithRelativeURL:(NSString*)relativeURL andHighlightLabels:(NSArray*)highlights;

@end
