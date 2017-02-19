//
//  ZFMapView.m
//  ZFLocation
//
//  Created by 曾凡怡 on 2017/2/18.
//  Copyright © 2017年 13072785111. All rights reserved.
//

#import "ZFMapView.h"

@implementation ZFMapView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"mapView die");
    self.delegate = nil;
}

- (void)setup{
    //显示定位图层
    self.showsUserLocation = YES;
    //追踪模式为默认普通模式
    self.userTrackingMode = BMKUserTrackingModeNone;
    
    self.delegate = self;
    // 放大级别,设置进入地图界面的放大比例 3-21
    self.zoomLevel = 18;
}



- (void)backCenterBtnAction
{
    //获取中心点
    BMKUserLocation *location = [self valueForKey:@"userLocation"];
    [self setCenterCoordinate:location.location.coordinate animated:YES];
}

#pragma mark - 代理方法.中心点改变
//在这个方法内添加界面元素 以适应外界为自动布局的情况
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    //获取资源路径 设置中心imageView 可以替换为自己项目的样式
    NSString *locIVPath = [[NSBundle mainBundle] pathForResource:@"/ZFMapResource.bundle/center_location.png" ofType:nil];
    UIImage *locIVImg = [UIImage imageWithContentsOfFile:locIVPath];
    UIImageView *locIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width / 2.0 - 15, self.bounds.size.height / 2 - 35, 30, 30)];
    locIV.image = locIVImg;
    _locIV = locIV;
    [self addSubview:locIV];
    
    
    // 添加返回中心点按钮
    UIButton *backCenterBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width - 50, self.bounds.size.height - 40, 30, 30)];
    NSString *backCenterBtnPath = [[NSBundle mainBundle] pathForResource:@"/ZFMapResource.bundle/back_location.png" ofType:nil];
    UIImage *backCenterBtnImg = [UIImage imageWithContentsOfFile:backCenterBtnPath];
    [backCenterBtn setImage:backCenterBtnImg forState:UIControlStateNormal];
    [backCenterBtn addTarget:self action:@selector(backCenterBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [backCenterBtn setBackgroundColor:[UIColor whiteColor]];
    backCenterBtn.layer.cornerRadius = 5;
    backCenterBtn.clipsToBounds = YES;
    [self addSubview:backCenterBtn];
}

- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
    //通知管理器用户已经开始拖动界面.
    if ([self.updateDelegate respondsToSelector:@selector(mapViewWillUpdateCenter)])
    {
        [self.updateDelegate mapViewWillUpdateCenter];
    }
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //制作弱引用替身
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.locIV.transform = CGAffineTransformMakeTranslation(0, -20);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.locIV.transform = CGAffineTransformIdentity;
        }];
    }];
    
    //通知中心点改变
    if ([self.updateDelegate respondsToSelector:@selector(mapView:didUpdateCenter:)])
    {
        //通知管理器中心点改变
        [self.updateDelegate mapView:self didUpdateCenter:self.centerCoordinate];
    }
}

@end
