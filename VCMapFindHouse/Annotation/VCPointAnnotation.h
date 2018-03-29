//
//  VCPointAnnotation.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/29.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface VCPointAnnotation : MAPointAnnotation

typedef NS_ENUM(NSInteger ,AnnotationType) {
    AnnotationTypeCity = 0,      //城市
    AnnotationTypeArea = 1,      //区县
    AnnotationTypeTown = 2,      //乡镇或商业区
    AnnotationTypeVillage = 3,   //小区
};

@property (nonatomic, assign) AnnotationType annotationType;
@property (nonatomic, assign) NSInteger      pointID;//标示点ID，可为区县/乡镇或小区ID

@end
