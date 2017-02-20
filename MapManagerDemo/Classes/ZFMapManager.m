//
//  ZFMapManager.m
//  ZFLocation
//
//  Created by 曾凡怡 on 2017/2/18.
//  Copyright © 2017年 13072785111. All rights reserved.
//

#import "ZFMapManager.h"
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Search/BMKPoiSearch.h>
#import <BaiduMapAPI_Base/BMKTypes.h>
#import <BaiduMapAPI_Search/BMKPoiSearchType.h>
@interface ZFMapManager ()<ZFMapViewProtocol,BMKGeoCodeSearchDelegate,BMKPoiSearchDelegate> {
    BMKMapManager* _mapManager;
}

@property(nonatomic,weak)ZFMapView *mapView;

/**
 地理编码搜索对象
 */
@property(nonatomic,strong)BMKGeoCodeSearch *geoSearcher;

/**
 poi搜索对象
 */
@property(nonatomic,strong)BMKPoiSearch *poiSearcher;


/**
 当前结果数组
 */
@property(nonatomic,strong)NSMutableArray *poiList;


/**
 当前中心点
 */
@property(nonatomic,assign)CLLocationCoordinate2D currentCenter;

/// 定位服务
@property(nonatomic,strong)BMKLocationService *locService;

/// 判断是否已经定位到当前位置
@property(nonatomic,assign)BOOL isCenter;

/// 搜索中心点附近的poi回调
@property(nonatomic,copy)NearByPoi nearByPoi;



@end

@implementation ZFMapManager

#pragma mark - 构造函数
+ (instancetype)sharedInstance
{
    static ZFMapManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ZFMapManager new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 要使用百度地图，请先启动BaiduMapManager
        _mapManager = [[BMKMapManager alloc]init];
        // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
        // BundleID 为 net.yeah.fanyizeng.---- 如果无法使用请更换为自己注册的BundleID
        BOOL ret = [_mapManager start:@"tUWhg88bXiiBnR39fri78LBhTEc0bN95"  generalDelegate:nil];
        if (!ret) {
            NSLog(@"manager start failed!");
        }
        
        
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
        
        
        
        //初始化地理编码检索对象
        _geoSearcher =[[BMKGeoCodeSearch alloc]init];
        _geoSearcher.delegate = self;
        
        //初始化poi搜索
        _poiSearcher = [[BMKPoiSearch alloc]init];
        _poiSearcher.delegate = self;
    }
    return self;
}


//懒加载可变数组
- (NSMutableArray *)poiList
{
    if (_poiList == nil) {
        _poiList = [NSMutableArray array];
    }
    return _poiList;
}



#pragma mark - 对外功能接口实现

/// 获取mapView;
- (ZFMapView *)getMap
{
    ZFMapView *mapView = [[ZFMapView alloc]init];
    _mapView = mapView;
    _mapView.updateDelegate = self;
    //启动LocationService
    [_locService startUserLocationService];

    //设置中心位置
    [self.mapView setCenterCoordinate:self.currentCenter animated:YES];
    
    return mapView;
}

- (NSString *)city
{
    if (_city == nil) {
        [self.locService startUserLocationService];
    }
    return _city;
}

/// 获取周边Poi
- (void)nearByPoi:(NearByPoi)nearByPoi
{
    self.isUpdateCity = YES;
    /// 将block缓存起来
    self.nearByPoi = nearByPoi;
    /// 将判断设为NO,认为不是当前位置
    self.isCenter = NO;
    /// 获取本地位置
    [self.locService startUserLocationService];
}

- (void)setIsCenter:(BOOL)isCenter
{
    if (_isCenter == NO && isCenter == YES) {
        //是手动获取的当前位置
        //反向地理编码成功 调用block
        if (_nearByPoi) {
            self.nearByPoi(self.poiList.copy);
        }
    }
    _isCenter = isCenter;
}






#pragma mark - BMKLocationServiceDelegate 定位更新回调获取当前位置
/**
 每次开始定位调用 更新map和获取城市信息
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //更新定位层位置信息
    [_mapView updateLocationData:userLocation];
    self.currentCenter = userLocation.location.coordinate;
    
    /// 获取城市信息
    if (self.isUpdateCity) {
        [self searchCityNameWithCoordinate2D:self.currentCenter];
    }
    
    // 获取一次当前位置信息
    [self mapView:self.mapView didUpdateCenter:self.currentCenter];
    
    // 只设置一次mapView的中心点
    if(_mapView != nil)
    {
        //获取中心点 用于设置mapView
        CLLocationCoordinate2D center = userLocation.location.coordinate;
        //设置中心位置
        [self.mapView setCenterCoordinate:center animated:YES];
        // 置空mapView. 只在mapView取出的时候设置一次中心点
        self.mapView = nil;
    }
    
    //停止定位
    [_locService stopUserLocationService];
}




#pragma mark - 发起搜索的参数
/// 获取当前城市信息
- (void)searchCityNameWithCoordinate2D:(CLLocationCoordinate2D)Coordinate2D
{
    self.isUpdateCity = YES;
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    /// 定位城市的关键字使用政府
    option.keyword = @"政府";
    //设定半径为5公里
    option.radius = 5000;
    option.location = Coordinate2D;
    BOOL flag = [self.poiSearcher poiSearchNearBy:option];
    NSLog(@"城市定位发送%@",flag ? @"成功" : @"失败");
}

/**
  周边热点搜索 根据反地理编码,传入一个坐标点
 */
- (void)searchPoiWithCoordinate2D:(CLLocationCoordinate2D)coordinate{
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = coordinate;
    BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    NSLog(@"周边反地理编码发送%@",flag ? @"成功" : @"失败");
}

//根据关键字搜索poi热点
- (void)searchWithKeyword:(NSString *)keyword;
{
    BMKCitySearchOption *option = [BMKCitySearchOption new];
    option.city = self.city;
    option.keyword = keyword;
    [self.poiSearcher poiSearchInCity:option];
}


#pragma mark - mapViewDelegate mapView移动坐标的时候主动回调
- (void)mapViewWillUpdateCenter
{
    //开始拖拽地图的回调
}


/**
 地图每次更新中心点调用的代理方法,方法内发起反地理编码检索
 */
- (void)mapView:(ZFMapView *)mapView didUpdateCenter:(CLLocationCoordinate2D)center
{
    self.isUpdateCity = NO;
    /// 地图停止拖拽回调
    [self searchPoiWithCoordinate2D:center];
}


- (void)mapViewRemoveFromSuperView:(ZFMapView *)mapView
{
    //地图从视图移除回调
    [_locService stopUserLocationService];
}

#pragma mark - BMKGeoCodeSearchDelegate poi搜索的返回值获取
/**
 *返回反地理编码搜索结果的代理方法 即当前位置附近
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        [self updatePoiListWith:result.poiList];
        ///用于手动获取信息的判断
        self.isCenter = YES;
    }
    else {
        NSLog(@"抱歉，未找到周边poi结果");
    }
}


//实现PoiSearchDeleage处理回调结果 这个方法用于定位当前城市和搜索功能
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        self.isUpdateCity = YES;
        [self updatePoiListWith:poiResultList.poiInfoList];
    }
}



/**
 处理搜索结果的私有方法
 */
- (void)updatePoiListWith:(NSArray *)poiList;
{
    // 清空可变数组
    [self.poiList removeAllObjects];
    /// 根据是否更新城市信息选择函数
    if (self.isUpdateCity) {
        [self updateCityWithPoiList:poiList];
    }else{
        [self updateWithPoiList:poiList];
    }
    // 通知代理更新了poi信息
    [[NSNotificationCenter defaultCenter]postNotificationName:KZFMapManagerPoiDidUpdateNotification object:self.poiList.copy];
}

- (void)updateWithPoiList:(NSArray *)poiList{
    for (BMKPoiInfo *info  in poiList)
    {
        //将信息保存到数组.
        [self.poiList addObject:@{ZFMapNameKEY:info.name,
                                  ZFMapAddressKEY:info.address,
                                  ZFMapPointKEY:[NSValue valueWithCGPoint:CGPointMake(info.pt.longitude, info.pt.latitude)],
                                  ZFMapDistanceKEY:@([self getDistanceSquared:CGPointMake(info.pt.longitude, info.pt.latitude) point:CGPointMake(self.currentCenter.longitude, self.currentCenter.latitude)])
                                  }];
    }

}

- (void)updateCityWithPoiList:(NSArray *)poiList{
    //记录行政区
    NSMutableDictionary *countDict = [NSMutableDictionary dictionary];
    
    for (BMKPoiInfo *info  in poiList)
    {
        //将信息保存到数组.
        [self.poiList addObject:@{ZFMapNameKEY:info.name,
                                  ZFMapAddressKEY:info.address,
                                  ZFMapPointKEY:[NSValue valueWithCGPoint:CGPointMake(info.pt.longitude, info.pt.latitude)],
                                  ZFMapDistanceKEY:@([self getDistanceSquared:CGPointMake(info.pt.longitude, info.pt.latitude) point:CGPointMake(self.currentCenter.longitude, self.currentCenter.latitude)])
                                  }];
        
        if(info.city.length > 0 && ![self.city isEqualToString:info.city])
        {
            NSLog(@"当前城市%@ -> %@",self.city,info.city);
            self.city = info.city;
            ///如果城市不一样 就发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KZFMapManagerCityDidChangeNotification object:@{ZFMapCityKEY:self.city}];
        }
        
        NSString * dis = [self districtWithAddress:info.address];
        
        /// 获取地址的行政区 然后统计数量
        if(countDict[dis] == nil && dis != nil)
        {
            countDict[dis] = @1;
        }else if (dis != nil){
            countDict[dis] = @(1 + [countDict[dis] integerValue]);
        }
    }
    
    /// 判断行政区谁最大
    __block NSInteger flag = 0;
    __block NSString *dis = nil;
    [countDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj integerValue] > flag)
        {
            //更改flag
            flag = [obj integerValue];
            //记录行政区
            dis = key;
        }
    }];
    /// 行政区改变发出通知
    if (dis.length > 0 && self.district != dis) {
        self.district = dis;
        [[NSNotificationCenter defaultCenter]postNotificationName:KZFMapManagerCityDidChangeNotification object:@{ZFMapDistrictKEY:self.district}];
    }

}


- (NSString *)districtWithAddress:(NSString *)address{
    // 取出行政区的地址
    if ([address rangeOfString:@"区"].length == 1) {
        NSString *area = [address substringToIndex:[address rangeOfString:@"区"].location+1];
        // 剔除市信息
        if ([area rangeOfString:@"市"].length == 1) {
            return [area substringFromIndex:[area rangeOfString:@"市"].location + 1];
        }
        return area;
    }
    
    // 取出县信息
    if ([address rangeOfString:@"县"].length == 1) {
        NSString *area = [address substringToIndex:[address rangeOfString:@"县"].location+1];
        // 剔除市信息
        if ([area rangeOfString:@"市"].length == 1) {
            return [area substringFromIndex:[area rangeOfString:@"市"].location + 1];
        }
        return area;
    }
    
    return nil;
}



#pragma mark - other 计算距离算法
/**
 传入经纬度,获取两个点的距离 返回的单位是米
 */
- (CGFloat)getDistanceSquared:(CGPoint) pt1 point:(CGPoint) pt2 {
    return sqrtf((pt1.x - pt2.x) * (pt1.x - pt2.x) + (pt1.y - pt2.y) * (pt1.y - pt2.y))  * 100000;
}


@end

