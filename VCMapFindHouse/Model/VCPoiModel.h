//
//  VCPoiModel.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/16.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "VCDAOModelBase.h"

@interface VCPoiModel : VCDAOModelBase

@property (nonatomic, assign) NSInteger pID;
@property (nonatomic, assign) double    lat;
@property (nonatomic, assign) double    lng;
@property (nonatomic, copy)   NSString  *name;
@property (nonatomic, assign) double    price;
@property (nonatomic, assign) NSInteger houseCount;
@property (nonatomic, assign) NSInteger cityID;//城市ID
@property (nonatomic, assign) NSInteger aID;//区县ID
@property (nonatomic, assign) NSInteger tID;//区域（乡镇）ID

@end
