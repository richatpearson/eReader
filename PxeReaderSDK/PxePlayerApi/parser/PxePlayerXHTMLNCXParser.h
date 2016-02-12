//
//  PxePlayerXHTMLNCXParser.h
//  PxeReader
//
//  Created by Mason, Darren J on 8/21/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxePlayerBaseParser.h"

/**
 
 */

@interface PxePlayerXHTMLNCXParser : NSObject <PxePlayerBaseParser>

@property(nonatomic,strong) NSMutableString *theContent;
@property(nonatomic,strong) NSString *parentId;

@end
