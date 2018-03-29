//
//  VCAreaAnnotationView.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/29.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface VCAreaAnnotationView : MAAnnotationView

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@end
