//
//  VCPoiModel.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/16.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "VCPoiModel.h"

@implementation VCPoiModel

+ (NSString *)getPrimaryKey
{
    return @"pID";
}

+ (NSString *)getTableName
{
    return @"vc_poi";
}

@end
