//
//  VCMapViewController.h
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/15.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

@interface VCMapViewController : UIViewController<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end
