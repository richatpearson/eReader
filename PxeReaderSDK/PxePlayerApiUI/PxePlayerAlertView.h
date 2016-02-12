//
//  PxePlayerAlertView.h
//  PxePlayerApi
//
//  Created by Saro Bear on 27/08/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A custom UIAlertView sub class for key value handling
 */
@interface PxePlayerAlertView : UIAlertView

/**
 This method would be called to add custom object into the dictionary stack
 @param NSString, value is a content or object to be stored in to the stack
 @param NSString, key is a string for identifying the object
 */
-(void)addCustomValue:(NSString*)value withKey:(NSString*)key;

/**
 This method would be called to remove object from the dictionary stack
 @param NSString, key is a string for identifying the object
 */
-(void)removeCustomValue:(NSString*)key;

/**
 This method would be called to get object from the dictionary stack
 @param NSString, key is a string for identifying the object
 @return NSString, returns the object from the identofied location
 */
-(NSString*)getCustomValue:(NSString*)key;

@end
