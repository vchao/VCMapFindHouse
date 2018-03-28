//
//  VCDAOModelBase.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/15.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "VCDAOModelBase.h"

@implementation VCDAOModelBase

static LKDBHelper* lkdbHelper = nil;

+(LKDBHelper *)getUsingLKDBHelper
{
    if (lkdbHelper == nil) {
        lkdbHelper = [[LKDBHelper alloc] initWithDBPath:TEMP_DB_PATH];
    }
    return lkdbHelper;
}

+(void) purgeUsingLKDBHelper
{
    lkdbHelper = nil;
}

@end
