//
//  PxePlayerAnnotationsQuery.h
//  PxeReader
//
//  Created by Tomack, Barry on 2/20/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayerNavigationsQuery.h"

@interface PxePlayerAnnotationsQuery : PxePlayerNavigationsQuery

/**
 A NSString variable to hold the context id
 */
@property (nonatomic, strong) NSString *content_uri;

/**
 A NSString variable to hold the book UUID
 */
//@property (nonatomic, strong) NSString  *bookUUID;

@end
