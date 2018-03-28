//
//  DBM.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/15.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabaseAdditions.h>

@class FMDatabaseQueue;

@interface DBM : NSObject

@property (nonatomic, retain) FMDatabase *dataBase;
@property (nonatomic, retain)FMDatabaseQueue *dbQueue;

+ (DBM *)shareInstance;
- (BOOL)loadDB;
- (void)closeDB;
- (NSString *)getDBPath;

- (BOOL)createTable:(FMDatabase*)db SQL:(NSString*)sql Table:(NSString *)table;
- (BOOL)executeTable:(FMDatabase*)db SQL:(NSString*)sql;
- (BOOL)deleteTable:(NSString *)table;

/**
 *  设置数据库版本号
 */
- (void)setDBVersion:(NSInteger)version;

/**
 *  获取当前数据库版本号
 */
- (NSInteger)getDBVersion;

@end
