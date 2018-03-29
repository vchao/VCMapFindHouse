//
//  VCAreaAnnotationView.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/29.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "VCAreaAnnotationView.h"

@implementation VCAreaAnnotationView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    if (!self.nameLabel) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, 64, 14)];
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.text = @"";
        [self addSubview:self.nameLabel];
    }
    
    if (!self.priceLabel) {
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, 64, 14)];
        self.priceLabel.font = [UIFont systemFontOfSize:14];
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        self.priceLabel.textColor = [UIColor whiteColor];
        self.priceLabel.text = @"";
        [self addSubview:self.priceLabel];
    }
}

@end
