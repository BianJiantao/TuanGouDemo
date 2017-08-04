//
//  TGMapViewController.m
//  团购HD
//
//  Created by BJT on 17/6/27.
//  Copyright © 2017年 BJT. All rights reserved.
//

#import "DPAPI.h"
#import "MJExtension.h"

#import <MapKit/MapKit.h>
#import "UIBarButtonItem+Extension.h"
#import "TGMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TGConst.h"
#import "TGDeal.h"
#import "TGBusiness.h"
#import "TGDealAnnotation.h"
#import "TGMetaTool.h"
#import "TGCategory.h"
#import "TGHomeTopItem.h"
#import "TGCategoryViewController.h"

@interface TGMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,DPRequestDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
/** 定位管理者, 用于定位 */
@property (nonatomic,strong) CLLocationManager *locMgr;
/** 地理编码,用于城市与经纬度转换 */
@property (nonatomic,strong) CLGeocoder *geoCoder;
@property (nonatomic,copy) NSString *city;
/**  分类 */
@property (nonatomic,weak) UIBarButtonItem *categoryItem;
/**  分类PopoverController */
@property (nonatomic,strong) UIPopoverController * categoryPopover;
/** 当前选中的分类名字 */
@property (nonatomic,copy) NSString *selectedCategoryName;
/** 最后一次网络请求 */
@property (nonatomic,strong) DPRequest *lastRuquest;

@end

@implementation TGMapViewController

- (CLGeocoder *)geoCoder
{
    if (_geoCoder == nil) {
        _geoCoder = [[CLGeocoder alloc] init];
    }
    return _geoCoder;
}

- (CLLocationManager *)locMgr
{
    if (_locMgr == nil) {
        _locMgr = [[CLLocationManager alloc] init];
        _locMgr.delegate = self;
    }
    return _locMgr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.locMgr respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locMgr requestAlwaysAuthorization];
        [self.locMgr requestWhenInUseAuthorization];
    }
    
    if ([CLLocationManager locationServicesEnabled]) { // 判断是否打开了位置服务
        [self.locMgr requestLocation]; // 开始更新位置
    }
    
    // 设置导航栏返回按钮
    UIBarButtonItem *backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highlightedImage:@"icon_back_highlighted"];
    
    // 分类菜单
    TGHomeTopItem *categoryTopItem = [TGHomeTopItem item];
    [categoryTopItem setTitle:@"全部分类"];
    [categoryTopItem setSubTitle:@""];
    [categoryTopItem addTarget:self action:@selector(categoryDidClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    self.categoryItem = categoryItem;
    self.navigationItem.leftBarButtonItems = @[backItem,categoryItem];
    
    // 监听分类切换
    [TGNotificationCenter addObserver:self selector:@selector(categoryDidChange:) name:TGCategoryDidChangeNotification object:nil];
    self.navigationItem.title = @"地图";
    
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
    
}

-(void)dealloc
{
    [TGNotificationCenter removeObserver:self];
}
/** 分类点击 */
-(void)categoryDidClick
{
    self.categoryPopover = [[UIPopoverController alloc] initWithContentViewController:[[TGCategoryViewController alloc] init]];
    [self.categoryPopover presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

/**
 *  分类改变
 */
-(void)categoryDidChange:(NSNotification *)noti
{
    TGCategory *category = noti.userInfo[TGSelectCategory];
    NSString *subcategoryName = noti.userInfo[TGSelectSubCategoryName];
    
    if(subcategoryName == nil || [subcategoryName isEqualToString:@"全部"]){
        
        self.selectedCategoryName = [category.name isEqualToString:@"全部分类"]?nil:category.name;
        
    }else{
        
        self.selectedCategoryName = subcategoryName;
    }
    
    // 更换顶部item的文字
    TGHomeTopItem *top = (TGHomeTopItem *)self.categoryItem.customView;
    [top setTitle:category.name];
    [top setIcon:category.icon highlightedIcon:category.highlighted_icon];
    [top setSubTitle:subcategoryName];
    // 关闭 popover
    [self.categoryPopover dismissPopoverAnimated:YES];
    // 移除之前的大头针模型
    [self.mapView removeAnnotations:self.mapView.annotations];
    // 发送请求
    [self mapView:self.mapView regionDidChangeAnimated:YES];
    
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MKMapViewDelegate代理方法
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
//    TGLog(@"%f,%f",coordinate.longitude,coordinate.latitude);
//    TGLog(@"%f,%f", mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta) ;

    [self.geoCoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        // 反地理编码失败,直接return
        if (error || placemarks.count == 0)  return ;
        
        CLPlacemark *plk = [placemarks firstObject];
        self.city = [plk.locality substringToIndex:plk.locality.length-1];
//        TGLog(@"%@,%@",plk.locality,plk.addressDictionary);
        
    }];

}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    TGLog(@"%f,%f", mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta) ;
    // 城市没有定位,直接返回
    if (self.city.length == 0) return;
    // 发送请求给服务器
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 城市
    params[@"city"] = self.city;
    // 类别
    if (self.selectedCategoryName) {
        params[@"category"] = self.selectedCategoryName;
    }
    // 经纬度
    params[@"latitude"] = @(mapView.region.center.latitude);
    params[@"longitude"] = @(mapView.region.center.longitude);
    params[@"radius"] = @(5000);
    self.lastRuquest = [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
    
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(TGDealAnnotation *)annotation
{
    // 返回 nil ,交给系统处理
    if (![annotation isKindOfClass:[TGDealAnnotation class]]) return nil;
        
    static NSString *ID = @"annotation";
    MKAnnotationView * annotationV =[mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annotationV == nil) {
        annotationV = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:ID];
        annotationV.canShowCallout = YES;
    }
    
    // 设置大头针模型
    annotationV.annotation = annotation;
//    TGLog(@"%@",annotation.icon);
    if (annotation.icon.length) {
        
        annotationV.image = [UIImage imageNamed:annotation.icon];
    }
    
    return annotationV;
}


-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
//    TGLog(@"%@",error);
}

#pragma mark - DPRequestDelegate 代理方法
-(void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if(request != self.lastRuquest)  return;
//    TGLog(@"%@",result);
    NSArray *deals =  [TGDeal objectArrayWithKeyValuesArray: result[@"deals"]];
    for (TGDeal * deal in deals) {
        
        TGCategory *category = [TGMetaTool categoryWithDeal:deal];
        
        for (TGBusiness *buis in deal.businesses) {
            
            TGDealAnnotation *anno = [[TGDealAnnotation alloc] init];
            anno.title = buis.name;
            anno.subtitle = deal.title;
            anno.coordinate = CLLocationCoordinate2DMake(buis.latitude, buis.longitude);
            anno.icon = category.map_icon;
            
            // 该商家已经在地图上存在,就不重复添加
            if([self.mapView.annotations containsObject:anno]) break;
            
            [self.mapView addAnnotation:anno];
            
        }
        
        
    }
    
}

-(void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    if(request != self.lastRuquest)  return;
    TGLog(@"%@",error);
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
//    TGLog(@"%@",locations);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    TGLog(@"%@",error);
}

@end
