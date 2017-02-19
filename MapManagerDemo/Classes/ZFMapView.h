//
//  ZFMapView.h
//  ZFLocation
//
//  Created by 曾凡怡 on 2017/2/18.
//  Copyright © 2017年 13072785111. All rights reserved.
//


#import <BaiduMapAPI_Map/BMKMapView.h>
@class ZFMapView;
@protocol ZFMapViewProtocol <NSObject>

- (void)mapViewWillUpdateCenter;

- (void)mapView:(ZFMapView *)mapView didUpdateCenter:(CLLocationCoordinate2D)center;

- (void)mapViewRemoveFromSuperView:(ZFMapView *)mapView;

@end

@interface ZFMapView : BMKMapView<BMKMapViewDelegate>

@property(nonatomic,weak)UIImageView *locIV;

@property(nonatomic,weak)id<ZFMapViewProtocol> updateDelegate;

@end
