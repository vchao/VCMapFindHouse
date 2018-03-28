//
//  VCAreaModel.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/15.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCDAOModelBase.h"

@interface VCAreaModel : VCDAOModelBase

@property (nonatomic, assign) NSInteger aID;
@property (nonatomic, assign) double    lat;
@property (nonatomic, assign) double    lng;
@property (nonatomic, copy)   NSString  *name;
@property (nonatomic, assign) double    price;
@property (nonatomic, assign) NSInteger cityID;

@end
