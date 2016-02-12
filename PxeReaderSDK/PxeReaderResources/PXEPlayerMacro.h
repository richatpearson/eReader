//
//  PXEPlayerMacro.h
//  PxeReader
//
//  Created by Tomack, Barry on 10/13/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

#ifndef PxeReader_PXEPlayerMacro_h
#define PxeReader_PXEPlayerMacro_h

#ifdef DEBUG
#    define DLog(fmt, ...) NSLog((@"PXE SDK : %s [%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#    define DLog(...)
#    define NSLog(...)
#endif

#endif
