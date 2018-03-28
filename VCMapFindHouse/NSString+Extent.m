//
//  NSString+Extent.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/28.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "NSString+Extent.h"

@implementation NSString (Extent)

- (CGSize)sizeWithFont:(UIFont *)font boundSize:(CGSize)size
{
    NSDictionary *attributes = @{ NSFontAttributeName : font};
    CGSize contentSize = [self boundingRectWithSize:size
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil].size;
    return contentSize;
}

@end
