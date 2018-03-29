//
//  VCMapViewController.m
//  VCMapFindHouse
//
//  Created by 任维超 on 2018/3/15.
//  Copyright © 2018年 vchao. All rights reserved.
//

#define is_iPhoneX          (([UIScreen mainScreen].bounds.size.height)==812)
#define kNavHeight          ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0 ? 64.0f : 44.0f)+(is_iPhoneX?24:0)

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
#import "VCVillageListView.h"

#import "UIImage+VCMapFindHouse.h"
#import "NSString+Extent.h"

@interface VCMapViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger cityID;
@property (nonatomic, strong) NSMutableArray *annotationArray;

@property (nonatomic, strong) VCVillageListView *vListView;

@property (nonatomic, strong) NSArray     *houseArray;
@property (nonatomic, assign) BOOL        openList;

@end

@implementation VCMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"地图找房";
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, kNavHeight, self.view.bounds.size.width, self.view.bounds.size.height-(kNavHeight))];
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 10;
    self.mapView.minZoomLevel = 9;
    [self.view addSubview:self.mapView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    headerView.backgroundColor = [UIColor clearColor];
    headerView.userInteractionEnabled = NO;
    
    if (!self.vListView) {
        self.vListView = [[VCVillageListView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (kNavHeight)) style:UITableViewStylePlain];
        self.vListView.translatesAutoresizingMaskIntoConstraints = NO;
        self.vListView.delegate = self;
        self.vListView.dataSource = self;
        self.vListView.backgroundColor = [UIColor clearColor];
        [self.vListView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.vListView setTableHeaderView:headerView];
        self.vListView.passthroughViews = [NSArray arrayWithObject:self.mapView];
        [self.view addSubview:self.vListView];
    }
    
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
    if (pa.annotationType < 3) {
        //放大
        mapView.centerCoordinate = pa.coordinate;
        if (pa.annotationType == AnnotationTypeTown) {
            [mapView setZoomLevel:15 animated:YES];
        }else if (pa.annotationType == AnnotationTypeArea) {
            [mapView setZoomLevel:13 animated:YES];
        }else{
            [mapView setZoomLevel:10 animated:YES];
        }
    }else{
        //小区房源列表
        NSLog(@"%ld----%ld", pa.pointID, pa.annotationType);
        
        self.houseArray = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", nil];
        [self.vListView reloadData];
        if (self.vListView.frame.origin.y != 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.mapView.frame = CGRectMake(0, kNavHeight, self.view.frame.size.width, 300);
                self.mapView.centerCoordinate = pa.coordinate;
                self.vListView.frame = CGRectMake(0, kNavHeight, self.view.frame.size.width, self.view.frame.size.height - (kNavHeight));
            } completion:^(BOOL finished) {
                self.openList = YES;
            }];
        }
    }
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

#pragma -mark

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.houseArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = self.houseArray[indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.openList) {
        if (scrollView.contentOffset.y <= -100) {
            self.openList = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.mapView.frame = CGRectMake(0, kNavHeight, self.view.frame.size.width, self.view.frame.size.height - (kNavHeight));
                self.vListView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (kNavHeight));
            } completion:^(BOOL finished) {
            }];
        }else if (scrollView.contentOffset.y < 0) {
            self.mapView.frame = CGRectMake(0, kNavHeight, self.view.frame.size.width, 300 - scrollView.contentOffset.y);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
