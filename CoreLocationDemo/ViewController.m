//
//  ViewController.m
//  CoreLocationDemo
//
//  Created by leergou on 16/7/13.
//  Copyright © 2016年 WhiteHouse. All rights reserved.
//

#import "ViewController.h"




#import "ViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;


@property (weak, nonatomic) IBOutlet UITextField *country;

@property (weak, nonatomic) IBOutlet UITextField *province;

@property (weak, nonatomic) IBOutlet UITextField *city;

@property (nonatomic, weak) IBOutlet UITextField *subLocality;

@property (weak, nonatomic) IBOutlet UITextField *street;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 开启定位
    [self startLocating];
    
}

#pragma mark - 1.定位
- (void)startLocating{
    
    if([CLLocationManager locationServicesEnabled]){
        
        // 具体每个属性的作用,自行查资料,网上很多
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter=10;
        
        // iOS8 之后需要做的设置,需要在Info.plist 文件中配置两个 key 值
        
        /**
         <key>NSLocationWhenInUseUsageDescription</key>
         <true/>
         <key>NSLocationAlwaysUsageDescription</key>
         <true/>
         
         将这个两个 key 值 设置为 Boolean YES
         
         */
        
        // 判断iOS版本
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0){
            [self.locationManager requestAlwaysAuthorization];
            //        [self.locationManager requestWhenInUseAuthorization];
        }
        //开始实时定位
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - 2.CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             // 获取的所有信息都在这个 placemark 对象中了,位置信息很具体,可以自己 NSLog 查看(demo 中已经提供了打印字典的文件,可以直接打印查看)
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             self.country.text = placemark.country;
             self.province.text = placemark.administrativeArea;
             self.city.text = placemark.locality;
             self.subLocality.text = placemark.subLocality;
             self.street.text = placemark.thoroughfare;
             
             if ([placemark.locality isEqualToString:placemark.subLocality]) {
                 
                 //四大直辖市获取到的 省 和 市 信息是一样的）
                 NSLog(@"四大直辖市");
             }
         }
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新,如果想实施定位,就不要调用此方法
    [manager stopUpdatingLocation];
}

// 获取失败调用
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

#pragma mark - 3.获取某地的经纬度
// 获取某一地点的经纬度
- (void)getLongitudeAndLatitudeWithCity:(NSString *)city
{
    NSString *oreillyAddress = city; // city 可以是中文或者英文
    CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
    [myGeocoder geocodeAddressString:oreillyAddress completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil){
            
            NSLog(@"Found %lu placemark(s).", (unsigned long)[placemarks count]);
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            NSLog(@"Longitude = %f", firstPlacemark.location.coordinate.longitude);
            NSLog(@"Latitude = %f", firstPlacemark.location.coordinate.latitude);
        }
        else if ([placemarks count] == 0 && error == nil){
            
            NSLog(@"Found no placemarks.");
        }
        else if (error != nil){
            
            NSLog(@"An error occurred = %@", error);
        }
    }];
}


@end

