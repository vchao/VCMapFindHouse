//
//  VCDAOModelBase.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/15.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LKDBHelper/LKDBHelper.h>

#define TEMP_DB_PATH [NSString stringWithFormat:@"%@/temp/temp.db",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]]

@interface VCDAOModelBase : NSObject

+(LKDBHelper *)getUsingLKDBHelper;
+(void) purgeUsingLKDBHelper;

@end
