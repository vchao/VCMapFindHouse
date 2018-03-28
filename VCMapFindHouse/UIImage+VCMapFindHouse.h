//
//  UIImage+VCMapFindHouse.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/28.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VCMapFindHouse)

/**
 *  返回一张指定size的指定颜色的圆形拉伸保护的纯色图片
 */
+ (UIImage *)circleAndStretchableImageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;

@end
