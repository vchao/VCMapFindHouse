//
//  VCMapViewController.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/15.
//  Copyright © 2018年 vchao. All rights reserved.
//

#import "VCMapViewController.h"
#import "VCAreaModel.h"
#import "VCTownModel.h"
#import "VCPoiModel.h"
#import <MJExtension/MJExtension.h>
#import <CoreLocation/CoreLocation.h>
#import "VCPointAnnotation.h"
#import "VCAreaAnnotationView.h"
#import "VCPoiAnnotationView.h"
#import <MAMapKit/MAAnnotation.h>

#import "UIImage+VCMapFindHouse.h"
#import "NSString+Extent.h"

@interface VCMapViewController ()

@property (nonatomic, assign) NSInteger cityID;
@property (nonatomic, strong) NSMutableArray *annotationArray;

@end

@implementation VCMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 10;
    self.mapView.minZoomLevel = 9;
    [self.view addSubview:self.mapView];
    
    self.annotationArray = [NSMutableArray new];
    [self loadTestingData];
}

- (void)loadTestingData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //本地测试数据
        NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2017100914001500" ofType:@"json"]];
        
        if (jsdata) {
            NSDictionary *cityDict = nil;
            
            @try {
                cityDict = [NSJSONSerialization JSONObjectWithData:jsdata options: NSJSONReadingAllowFragments error:nil];
            }
            @catch (NSException *exception) {
                NSLog(@"exception :%@", exception);
            }
            @finally{
                
            }
            
            self.cityID = [[cityDict objectForKey:@"cityID"] integerValue];
            NSString  *cityName = [cityDict objectForKey:@"cityName"];
            NSArray *areas = [cityDict objectForKey:@"areas"];
            for (NSDictionary *dic in areas) {
                VCAreaModel *area = [VCAreaModel mj_objectWithKeyValues:dic];
                area.cityID = self.cityID;
                [area saveToDB];
                
                NSArray *towns = [dic objectForKey:@"towns"];
                for (NSDictionary *townDict in towns) {
                    VCTownModel *town = [VCTownModel mj_objectWithKeyValues:townDict];
                    town.cityID = self.cityID;
                    town.aID = area.aID;
                    [town saveToDB];
                    
                    NSArray *pois = [townDict objectForKey:@"pois"];
                    for (NSDictionary *poiDict in pois) {
                        VCPoiModel *poi = [VCPoiModel mj_objectWithKeyValues:poiDict];
                        poi.cityID = self.cityID;
                        poi.aID = area.aID;
                        poi.tID = town.tID;
                        [poi saveToDB];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //主线程更新地图
                [self refreshAnnotation];
            });
        }
    });
    
}

#pragma MAMapViewDelegate
//地图缩放结束后
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
//    [self refreshAnnotation];
}

//地图移动结束后
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction
{
    NSLog(@">>>>>>zoom level:%f", mapView.zoomLevel);
    [self refreshAnnotation];
}

//地图区域改变完成后
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MACoordinateRegion region = mapView.region;
    [self refreshAnnotation];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if (self.mapView.zoomLevel >= 15) {
        static NSString *customReuseIndetifier = @"customPoiReuseIndetifier";
        
        VCPoiAnnotationView *annotationView = (VCPoiAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil) {
            annotationView = [[VCPoiAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            annotationView.canShowCallout = NO;
            annotationView.highlighted = NO;
            annotationView.draggable = YES;
            annotationView.calloutOffset = CGPointMake(0, -24);
        }
        
        CGSize titleSize = [annotation.title sizeWithFont:annotationView.nameLabel.font boundSize:CGSizeMake(self.view.frame.size.width, 30)];
        CGSize subtitleSize = [annotation.subtitle sizeWithFont:annotationView.nameLabel.font boundSize:CGSizeMake(self.view.frame.size.width, 30)];
        CGFloat width = titleSize.width + subtitleSize.width + 24;
        annotationView.image = [UIImage createImageWithColor:[UIColor clearColor] size:CGSizeMake(width, 34)];
        annotationView.bgView.frame = CGRectMake(0, 0, width, 30);
        annotationView.bottomBGView.frame = CGRectMake((width-8)/2.f, 30, 8, 4);
        annotationView.nameLabel.frame = CGRectMake(10, 0, titleSize.width, 30);
        annotationView.countLabel.frame = CGRectMake(CGRectGetMaxX(annotationView.nameLabel.frame) + 4, 0, subtitleSize.width, 30);
        annotationView.nameLabel.text = annotation.title;
        annotationView.countLabel.text = annotation.subtitle;
        return annotationView;
    }else{
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        
        VCAreaAnnotationView *annotationView = (VCAreaAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil) {
            annotationView = [[VCAreaAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            annotationView.canShowCallout = NO;
            annotationView.highlighted = NO;
            annotationView.draggable = YES;
        }
        
        annotationView.image = [UIImage circleAndStretchableImageWithColor:[UIColor colorWithRed:80/255.f green:180/255.f blue:115/255.f alpha:0.9] size:CGSizeMake(64, 64)];
        annotationView.nameLabel.text = annotation.title;
        annotationView.priceLabel.text = annotation.subtitle;
        return annotationView;
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    VCPointAnnotation *pa = (VCPointAnnotation *)view.annotation;
    NSLog(@"%ld----%ld", pa.pointID, pa.annotationType);
}

- (void)refreshAnnotation
{
    MACoordinateRegion region = self.mapView.region;
    CLLocationCoordinate2D center = region.center;
    MACoordinateSpan span = region.span;
    CGFloat southLat = center.latitude - span.latitudeDelta/2.f;
    CGFloat northLat = center.latitude + span.latitudeDelta/2.f;
    CGFloat eastLng = center.longitude + span.longitudeDelta/2.f;
    CGFloat westLng = center.longitude - span.longitudeDelta/2.f;
    if (self.annotationArray.count) {
        [self.mapView removeAnnotations:self.annotationArray];
        [self.annotationArray removeAllObjects];
    }
    if (self.mapView.zoomLevel >= 15) {
        LKDBHelper* globalHelper = [VCDAOModelBase getUsingLKDBHelper];
        NSString *sqlStr = [[NSString alloc] initWithFormat:@"select * from @t where cityID=%ld and lat >= %f and lat <= %f and lng >= %f and lng <= %f", self.cityID, southLat, northLat, westLng, eastLng];
        NSArray *poiArray = [globalHelper searchWithSQL:sqlStr toClass:[VCPoiModel class]];
        for (VCPoiModel *model in poiArray) {
            VCPointAnnotation *pa = [[VCPointAnnotation alloc] init];
            pa.annotationType = AnnotationTypeVillage;
            pa.pointID = model.pID;
            pa.coordinate = CLLocationCoordinate2DMake(model.lat, model.lng);
            pa.title = [NSString stringWithFormat:@"%@ %.1f万", model.name, model.price/10000.f];
            pa.subtitle = [NSString stringWithFormat:@"%ld套", model.houseCount];
            [self.annotationArray addObject:pa];
            [self.mapView addAnnotation:pa];
        }
    }else if (self.mapView.zoomLevel >= 12.5) {
        LKDBHelper* globalHelper = [VCDAOModelBase getUsingLKDBHelper];
        NSString *sqlStr = [[NSString alloc] initWithFormat:@"select * from @t where cityID=%ld and lat >= %f and lat <= %f and lng >= %f and lng <= %f", self.cityID, southLat, northLat, westLng, eastLng];
        NSArray *townArray = [globalHelper searchWithSQL:sqlStr toClass:[VCTownModel class]];
        for (VCTownModel *model in townArray) {
            VCPointAnnotation *pa = [[VCPointAnnotation alloc] init];
            pa.annotationType = AnnotationTypeTown;
            pa.pointID = model.tID;
            pa.coordinate = CLLocationCoordinate2DMake(model.lat, model.lng);
            pa.title = model.name;
            pa.subtitle = [NSString stringWithFormat:@"%.1f万", model.price/10000.f];
            [self.annotationArray addObject:pa];
            [self.mapView addAnnotation:pa];
        }
    }else{
        LKDBHelper* globalHelper = [VCDAOModelBase getUsingLKDBHelper];
        NSString *sqlStr = [[NSString alloc] initWithFormat:@"select * from @t where cityID=%ld and lat >= %f and lat <= %f and lng >= %f and lng <= %f", self.cityID, southLat, northLat, westLng, eastLng];
        NSArray *areaArray = [globalHelper searchWithSQL:sqlStr toClass:[VCAreaModel class]];
        for (VCAreaModel *model in areaArray) {
            VCPointAnnotation *pa = [[VCPointAnnotation alloc] init];
            pa.annotationType = AnnotationTypeArea;
            pa.pointID = model.aID;
            pa.coordinate = CLLocationCoordinate2DMake(model.lat, model.lng);
            pa.title = model.name;
            pa.subtitle = [NSString stringWithFormat:@"%.1f万", model.price/10000.f];
            [self.annotationArray addObject:pa];
            [self.mapView addAnnotation:pa];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
