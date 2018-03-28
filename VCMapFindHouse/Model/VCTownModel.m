//
//  VCTownModel.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/16.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "VCTownModel.h"

@implementation VCTownModel

+ (NSString *)getPrimaryKey
{
    return @"tID";
}

+ (NSString *)getTableName
{
    return @"vc_town";
}

@end
