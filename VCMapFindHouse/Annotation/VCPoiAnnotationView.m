//
//  VCPoiAnnotationView.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/28.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "VCPoiAnnotationView.h"

@interface VCPoiAnnotationView()

@end

@implementation VCPoiAnnotationView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    if (!self.bgView) {
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        self.bgView.backgroundColor = [UIColor colorWithRed:80/255.f green:180/255.f blue:115/255.f alpha:0.9];
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.cornerRadius = 15.f;
        self.bgView.userInteractionEnabled = NO;
        [self addSubview:self.bgView];
    }
    if (!self.bottomBGView) {
        self.bottomBGView = [[UIImageView alloc] initWithFrame:CGRectMake(21, 30, 8, 4)];
        self.bottomBGView.image = [UIImage imageNamed:@"poi_bg_bottom"];
        self.bottomBGView.backgroundColor = [UIColor clearColor];
        self.bottomBGView.userInteractionEnabled = NO;
        [self addSubview:self.bottomBGView];
    }
    if (!self.nameLabel) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.text = @"";
        [self addSubview:self.nameLabel];
    }
    
    if (!self.countLabel) {
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 10, 30)];
        self.countLabel.font = [UIFont systemFontOfSize:14];
        self.countLabel.textAlignment = NSTextAlignmentLeft;
        self.countLabel.textColor = [UIColor whiteColor];
        self.countLabel.text = @"";
        [self addSubview:self.countLabel];
    }
}

@end
