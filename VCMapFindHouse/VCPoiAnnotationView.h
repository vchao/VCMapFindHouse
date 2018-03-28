//
//  VCPoiAnnotationView.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/28.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface VCPoiAnnotationView : MAAnnotationView

@property (nonatomic, strong) UIView  *bgView;
@property (nonatomic, strong) UIImageView *bottomBGView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end
