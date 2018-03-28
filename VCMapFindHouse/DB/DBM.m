//
//  DBM.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/15.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "DBM.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import <LKDBHelper/LKDBHelper.h>

#import "VCAreaModel.h"
#import "VCTownModel.h"
#import "VCPoiModel.h"

#define IS_NSString(x) ([x isKindOfClass:[NSString class]] && x.length>0)
#define IS_NSStringEx(x) (!(x==nil || [x isKindOfClass:[NSNull class]]) && [x isKindOfClass:[NSString class]] && x.length>0 && ![x isEqualToString:@"(null)"]&& ![x isEqualToString:@"<null>"])

@interface DBM ()
@property (nonatomic, strong) NSArray *needCreateModelClass;
@end

@implementation DBM

+ (DBM *)shareInstance
{
    static DBM *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DBM alloc] init];
    });
    return instance;
}

- (void)dealloc
{
    [self closeDB];
    self.dbQueue = nil;
    self.dataBase = nil;
}

- (BOOL)loadDB
{
    [self closeDB];//先关闭
    
    if (IS_NSStringEx(TEMP_DB_PATH)) {
        [self checkFolderExistsAtPath:TEMP_DB_PATH];
        self.dataBase = [FMDatabase databaseWithPath:TEMP_DB_PATH];//获取DB文件
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:TEMP_DB_PATH];//获取FM队列
        [DBM shareInstance].dataBase = self.dataBase;
        [DBM shareInstance].dbQueue = self.dbQueue;
        NSLog(@"loadDB==>checkAddedTables:%@", TEMP_DB_PATH);
        if ([self.dataBase open]) {
            [self checkAddedTables];
            return YES;
        } else {
            self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:TEMP_DB_PATH];//获取
            if ([self.dataBase open]) {
                [self checkAddedTables];
                return YES;
            }
            NSLog(@"不能打开数据库!!!");
            return NO;
        }
    }
    return NO;
}

- (NSString *)getDBPath
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mapfindhouse.db"];
    return path;
}

- (void)checkAddedTables
{
    [[DBM shareInstance] setDBVersion:3];
    LKDBHelper *helper = [VCDAOModelBase getUsingLKDBHelper];
    for (Class modelClass in self.needCreateModelClass) {
        if (![helper getTableCreatedWithClass:modelClass]) {
            NSLog(@"create %@ table error", [modelClass getTableName]);
        }
    }
}

- (BOOL)createTable:(FMDatabase*)db SQL:(NSString*)sql Table:(NSString *)table
{
    BOOL temp = [db executeUpdate:sql];
    return temp;
}

- (BOOL)executeTable:(FMDatabase*)db SQL:(NSString*)sql
{
    BOOL temp = [db executeUpdate:sql];
    return temp;
}

- (BOOL)deleteTable:(NSString *)table
{
    __block BOOL tf = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [@"DROP TABLE " stringByAppendingString:table];
        tf = [db executeUpdate:sql];
    }];
    
    return tf;
}

- (void)closeDB
{
    [_dataBase close];
    
    self.dbQueue = nil;
    self.dataBase = nil;
}

- (void)setDBVersion:(NSInteger)version{
    __block NSInteger dbVersion = version;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *query = [NSString stringWithFormat:@"pragma user_version = %zd", dbVersion];
        FMResultSet *rs = [db executeQuery:query];
        [rs next];
        [rs close];
    }];
}

- (NSInteger)getDBVersion{
    __block NSInteger version = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"pragma user_version"];
        if ([rs next]) {
            version = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return version;
}

- (NSArray *)needCreateModelClass
{
    if (!_needCreateModelClass) {
        _needCreateModelClass = [NSArray arrayWithObjects:
                                 [VCAreaModel class],
                                 [VCTownModel class],
                                 [VCPoiModel class],
                                 nil];
    }
    return _needCreateModelClass;
}

- (void)checkFolderExistsAtPath:(NSString *)path
{
    BOOL isDir = false;
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir && isDirExist)) {
        NSError *error;
        BOOL isDirCreate = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!isDirCreate) {
            NSLog(@"创建目录失败");
        } else {
            NSLog(@"创建目录成功");
        }
    } else {
        NSLog(@"目录已经存在");
    }
}

@end
