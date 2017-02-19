//
//  ZFMapManager.h
//  ZFLocation
//
//  Created by 曾凡怡 on 2017/2/18.
//  Copyright © 2017年 13072785111. All rights reserved.
//


#import "ZFMapView.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>

#define _MapMgr ([ZFMapManager sharedInstance])

typedef void(^NearByPoi)(NSArray *);

@interface ZFMapManager : NSObject <BMKMapViewDelegate,BMKLocationServiceDelegate>

/// 当前城市 可能为nil 获取一次后如果为nil会自动刷新当前城市位置,并抛出通知. 
@property(nonatomic,copy)NSString *city;

/// 行政区 可能为nil 通过调用 searchCityNameWithCoordinate2D 接收通知来获取行政区. 百度API没有开发直接查询行政区的接口,这里通过分析地址返回一个不太准确的行政区信息 若需要准确行政区需要改用高德API
@property(nonatomic,copy)NSString *district;

/// 是否更新城市信息 默认为NO nearByPoi  searchCityName 会自动打开
@property(nonatomic,assign)BOOL isUpdateCity;

/// 单例对象
+ (instancetype)sharedInstance;

/// 获取懒加载的mapView;
- (ZFMapView *)getMap;


/**
 异步获取附近POI热点信息 通常用来确定用户当前所在位置最近的热点信息,作为默认收货地址
 */
- (void)nearByPoi:(NearByPoi)result;


/**
 异步查询地址信息 结果通过通知抛出. 用来处理关键字搜索 只会搜索当前城市信息.
 */
- (void)searchWithKeyword:(NSString *)keyword;


/**
 根据一个坐标查询地理编码,获取地址信息.通常用来获取一个地理位置的 行政市 区 信息
 */
- (void)searchCityNameWithCoordinate2D:(CLLocationCoordinate2D)Coordinate2D;


/// 每次周围热点信息更新都会发送这个通知  热点信息的数组直接从Object对象取出
#define KZFMapManagerPoiDidUpdateNotification   @"KZFMapManagerPoiDidUpdateNotification"

/**
 地点名 NSString
 */
#define ZFMapNameKEY @"ZFMapNameKEY"
/**
 地址 NSString
 */
#define ZFMapAddressKEY @"ZFMapAddressKEY"
/**
 坐标 CGPoint X:经度 Y:纬度
 */
#define ZFMapPointKEY @"ZFMapPointKEY"

/**
 距离 float 单位米
 */
#define ZFMapDistanceKEY @"ZFMapDistanceKEY"


/// 当前城市/行政区 更新发送通知 热点信息的数组直接从Object对象取出
#define KZFMapManagerCityDidChangeNotification   @"KZFMapManagerCityDidChangeNotification"


/**
 城市名 NSString
 */
#define ZFMapCityKEY @"ZFMapCityKEY"


/**
 行政区 NSString
 */
#define ZFMapDistrictKEY @"ZFMapDistrictKEY"

/// 点击选中位置变更发送通知
#define KZFMapManagerLocationDidSelectedNotification  @"KZFMapManagerLocationDidSelectedNotification"
@end
